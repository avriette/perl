package Data::EnCase::HashList::Hash;

use 5.012004;
use strict;
use warnings;

use base qw{ Class::Accessor };
use Params::Validate qw{ :all };
use File::Basename;
use File::Slurp;
use Scalar::Util qw{ blessed };

our @ISA = qw();

our $VERSION = '0.1';

our @reqd_attributes = qw{
	cksum
	filename
};

our @attributes = qw {
	fileid
	directory
	filesize
	datemodified
	timemodified
	timezone
	comments
	dateaccessed
	timeaccessed
};

our %template = map { $_ => '' } (@reqd_attributes, @attributes);

=cut

Specification for EnCase hashlist file taken from:

http://www.nsrl.nist.gov/Documents/CreatingHashSetsmanually.pdf

by Sharren Redmond

=cut

sub new {
	my $class = shift;

	validate( @_, { 
		(map { $_ => { type => SCALAR, optional => 0 } } @reqd_attributes),
		(map { $_ => { type => SCALAR, optional => 1 } } @attributes),
	} );

	my %object = %template;
	my %args   = (@_);

	# get default keys and values
	foreach my $key (keys %template) {
		if (defined $args{$key}) {
			$object{$key} = $args{$key};
		}
		else {
			$object{$key} = $template{$key};
		}
	}

	# See File::Basename
	my ($filename, $dirname) = fileparse( $object{filename} );

	if (length $dirname and not length $object{directory}) {
		$object{directory} = $dirname;
		$object{filename}  = $filename;
	}

	$class->follow_best_practice();
	$class->mk_ro_accessors( @reqd_attributes );
	$class->mk_accessors( @attributes );

	return bless \%object, $class;
}

sub new_from_cksum {
	my $class = shift;

	my @hashes;

	# This should be an array of lines.
	# It's ugly. I know. But it works, and it's quick. This should cover both
	# Solaris and Linux and seems to work with Darwin.
	foreach my $line (@_) {
	  my $fn = substr $line, 5, (index $line, ')') - 5;
	  my ($hash) = (split /\s+/, $line)[-1];
	  if ($hash =~ /\//) {
	    $fn = $hash;
	    $hash = substr $line, 0, 32;
	  }
	  
		# Validation happens in new() above
		push @hashes, $class->new(
			cksum => $hash,
			filename => $fn,
		) unless $hash =~ /[^a-f0-9]/;
	}

	# Note, this may be empty if your list of hashes was malformatted.
	return \@hashes;
}

1;

package Data::EnCase::HashList;

use 5.012004;
use strict;
use warnings;

use base qw{ Class::Accessor };
use Params::Validate qw{ :all };

our @ISA = qw();

our $VERSION = '0.1';

our @reqd_attributes = qw{
	hashes
	filename
};

sub new {
	my $class = shift;

	foreach my $arg (@_) { 
		validate( $arg, 
			{ 
				type => OBJECT, 
				can => [ qw{ get_filename get_cksum } ],
			}
		);
	}
	$class->follow_best_practice();
	$class->mk_ro_accessors( @reqd_attributes );

	return bless { hashes => \@_, filename => '' }, $class;
}

sub serialize {
	validate( @_,
		{
			# self
			type => OBJECT,
			can  => 'get_hashes',
		},
		{
			# what is the file name we are to write?
			type => SCALAR,
			optional => 0,
		},
	);

	my $self = shift;

	my $hke_fileid;
	
	my $hsh_header = <<"HEADER"
"file_id","hashset_id","file_name","directory","hash","file_size","date_modified","time_modified","time_zone","comments","date_accessed","time_accessed"


HEADER
 
	my $hke_header = <<"HEADER"
"hashset_id","name","vendor","package","version","authenicated_flag","notable_flag","initials","num_of_files","description","date_loaded"


HEADER

	my @list = ( );
	foreach my $hash (@{ $self->get_hashes() }) {
		if (not defined $hke_fileid) {
			$hke_fileid = $hash->get_fileid() ? $hash->get_fileid : 1;
		}
		# Note, these default to the empty string, which is okay with EnCase.
		my $line = '"'. (join '","', 
			length $hash->get_fileid() ? $hash->get_fileid : 1,
			$hash->get_hashsetid() eq $hash->get_fileid() ? $hash->get_hashsetid() : 1,
			$hash->get_filename(),
			$hash->get_directory(),
			$hash->get_cksum(),
			$hash->get_filesize(),
			$hash->get_datemodified(),
			$hash->get_timemodified(),
			$hash->get_timezone(),
			$hash->get_comments(),
			$hash->get_dateaccessed(),
			$hash->get_timeaccessed(),
		).'"';
		push @list, $line;
	}

	my %khe_attrs = (
		hashset_id         => $hke_fileid,
		name               => blessed $self,
		# JAA_perl-5.12.2
		vendor             => 'JAA'.'_'.$^X.'-'.$^V,
		package            => blessed $self,
		version            => '',
		authenticated_flag => 1,
		notable_flag       => 0,
		initials           => 'JAA',
		num_of_files       => 0,
		description        => 'perl-generated encase hash set',
		date_loaded        => scalar localtime(time()),
	);


}


1;

=cut

the hke file looks like:

hashset_id
name
vendor
package
version
authenicated_flag
notable_flag
initials
num_of_files
description
date_loaded

=cut

__END__

=head1 NAME

Data::EnCase::HashList - Perl module to create EnCase hashsets

=head1 SYNOPSIS

  use Data::EnCase::HashList;

	my $set = Data::EnCase::HashList->new( @cksum_lines );
	foreach my $hash ($set->get_hashes()) {
		say $hash->get_cksum();
		say $hash->get_filename();
		say $hash->get_fileid();
		say $hash->get_directory();
		say $hash->get_filesize();
		say $hash->get_datemodified();
		say $hash->get_timemodified();
		say $hash->get_timezone();
		say $hash->get_comments();
		say $hash->get_dateaccessed();
		say $hash->get_timeaccessed();
	}


=head1 DESCRIPTION

Given an input of lines from cksum(1) on Unix (Linux, Darwin, and Solaris are
supported; others may work), this module will generate a container object that
L<Data::EnCase::HashList::Hash> objects with the requisite fields sufficient 
for producing an EnCase hashlist. Because Unix doesn't give us information 
like timezone and comments from cksum, these are up to you to modify. EnCase 
doesn't mind if they're not there.

=head1 AUTHOR

Jane A Avriette, E<lt>jane@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jane A Avriette

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
