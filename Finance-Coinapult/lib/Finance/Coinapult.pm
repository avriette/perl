package Finance::Coinapult;

use 5.12.0;

use Params::Validate qw{ :all };
use Finance::Coinapult::Environment;
use Finance::Coinapult::Request;
use WWW::Curl::Simple;
use HTTP::Request::Common;
use HTTP::Headers;
use JSON::MaybeXS;
use Data::GUID;

sub new {
	my $class = shift;

	my %args = @_;  # this is validated in F::C::Environment
	my $self = { };
	$self->{env} = Finance::Coinapult::Environment->new( %args );

	return bless $self, $class;
}

# Note we are following the studly caps here because that's what is in
# the api spec, regardless of whether this is the Perlish(tm) way to do
# things or not.
sub getRates {
	my $self = shift;

	validate( @_, {
		inCurrency => {
			optional => 0,
			type     => SCALAR,
		},
		outCurrency => {
			optional => 0,
			type     => SCALAR,
		},
		amount => {
			optional => 0,
			type     => SCALAR
		},
	} );

	# Note that encoding gets screwy here if $timestamp is a string vs an int.
	# Yes, in perl. (via GP)
	my $timestamp = sprintf '%d', time();
	my $hdr  = HTTP::Headers->new(
		'cpt-key' => $self->{env}->get_key(),


}

"sic semper tyrannis";

# jane@cpan.org // vim:tw=80:ts=2:noet

=pod

=head1 NAME

Finance::Coinapult

=head1 ABSTRACT

Public API access for Coinapult in perl. Ta-da!

=head1 SYNOPSIS

  use Finance::Coinapult;
  my $c = Finance::Coinapult->new(
    key    => 'asdkjakjad',   # This is not actually a real key
    secret => 'sdlkjdlkjasd', # This is not actually a real secret
  );
  $c->get_balance(); # and so on

=head1 DESCRIPTION

C<Finance::Coinapult> aims to create a shiny perl package for interfacing
with the Coinapult public API.

=head1 ACCESSORS

Some C<accessors>

=head1 METHODS

Some C<methods>...

=head1 SEE ALSO

Stuff should go here.

=head1 BUGS

Bugs. Probably report them.

=head1 AUTHOR

Jane Avriette, E<lt>jane@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Jane Avriette

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
