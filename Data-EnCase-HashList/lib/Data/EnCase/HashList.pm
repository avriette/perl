package Data::EnCase::HashList;

use 5.12.0;
use warnings;

use base qw{ Class::Accessor };
use Params::Validate qw{ :all };

our $VERSION = '0.1';

our @reqd_attributes = qw{
	hashes
	filename
};

sub new {
	my $class = shift;

	my $hashes   = $_[0];
	my $filename = $_[1];

	$class->follow_best_practice();
	$class->mk_ro_accessors( @reqd_attributes );

	return bless { hashes => $hashes, filename => $filename }, $class;
}

sub serialize {
	validate_pos( @_,
		{
			# self
			type => OBJECT,
			can  => qw{ get_hashes get_filename },
		},
	);

	my $self = shift;

	my $hke_fileid;
	
	my $hsh_header = <<"HEADER";
"file_id","hashset_id","file_name","directory","hash","file_size","date_modified","time_modified","time_zone","comments","date_accessed","time_accessed"


HEADER
 
	my $hke_header = <<"HEADER";
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
			$hash->get_hash(),
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

	my %hke_attrs = (
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

	my $hsh_name = $self->get_filename().".hsh";
	my $hke_name = $hsh_name.".hke";

	# The list of hashes
	write_file( $hsh_name, 
		$hsh_header,
		@list,
	)
		or return undef;

	# The "hash key" file
	write_file( $hke_name,
		$hke_header,
		'"'.(join '","',@hke_attrs{ qw{
			hashset_id
			name
			vendor
			package
			version
			authenticated_flag
			notable_flag
			initials
			num_of_files
			description
			date_loaded
		} } ).'"',
	)
		or return undef;

	return "Success!";

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

	my $set = Data::EnCase::HashList->new( @hash_lines );
	foreach my $hash ($set->get_hashes()) {
		say $hash->get_hash();
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

Given an input of lines from md5(1) on Unix (Linux, Darwin, and Solaris are
supported; others may work), this module will generate a container object that
L<Data::EnCase::HashList::Hash> objects with the requisite fields sufficient 
for producing an EnCase hashlist. Because Unix doesn't give us information 
like timezone and comments from md5, these are up to you to modify. EnCase 
doesn't mind if they're not there.

=head1 AUTHOR

Jane A Avriette, E<lt>jane@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jane A Avriette

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
