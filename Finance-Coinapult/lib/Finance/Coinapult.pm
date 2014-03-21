package Finance::Coinapult;

use 5.12.0;

use Params::Validate qw{ :all };
use Crypt::Mac::HMAC qw{ hmac_hex };
use Finance::Coinapult::RequestFactory;
use Finance::Coinapult::Environment;
use Finance::Coinapult::Request;
use HTTP::Request::Common;
use WWW::Curl::Simple;
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
#

# Convert from one currency (e.g., 'BTC', 'EUR', etc) to another
#
sub convert { # {{{ convert
	my $self = shift;

	# This is standard for all api calls
	# XXX: should this be a method? who would use it?
	my $uri_loc = "/t/convert";

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

	my $args = { @_ };

	# Note that encoding gets screwy here if $timestamp is a string vs an int.
	# Yes, in perl. (via GP)
	$args->{timestamp} = sprintf '%d', time();

	# Just a unique (per 24h) identifier
	$args->{nonce} = Data::GUID->new()->as_string();

	# Package it, it has to be sorted
	my $sorted_payload = [ map { $_ => $args->{$_} } sort keys %{ $args } ];

	my $req =
		POST $self->{env}->get_api_base().$uri_loc,
			'cpt-key'  => $self->{env}->get_key(),
			'cpt-hmac' => hmac_hex( 'SHA512',
				$self->secret(),
				JSON->new()->canonical()->encode( {
					map { $_ => $args->{$_} } sort keys %{ $args }
				} )
			),
			Content => $sorted_payload; # POST

	my $r = Finance::Coinapult::Request->new(
		request => $req,
		payload => $sorted_payload,
		guid    => $args->{nonce},
		key     => $self->key(),
	);

	my $c = WWW::Curl::Simple->new();
	my $content = $c->request( $r->{request} )->content();

	return {
		curl    => $c,
		request => $r,
		data    => $content,
	};

} # }}} convert

sub receive { # {{{ receive
	my $self = shift;

=cut {{{ json args

// POST arguments
{
	"timestamp"   : // unix timestamp
	"nonce"       : // string
	"currency"    : // 'btc', 'usd', etc
	"outCurrency" : // 'btc', 'usd', etc, optional
	"method"      : // 'internal' or 'bitcoin'
	"amount"      : // float (optional)
	"outAmount"   : // float (optional)
	"callback"    : // url, optional
}

=cut }}}

	# This is standard for all api calls
	# XXX: should this be a method? who would use it?
	my $uri_loc = "/t/receive";

	state $spec = {
		( map {
			$_ => {
				optional => 0,
				type     => SCALAR,
			}
		} qw{ method currency } ),

		( map {
			$_ => {
				optional => 1,
				type     => SCALAR
			}
		} qw{ outCurrency amount outAmount callback } ),
	};

	validate( @_, $spec );

	my $args = { @_ };

	return Finance::Coinapult::RequestFactory->mk_request( $self,
		params => $args,
		uri    => $uri_loc,
	);

} # }}} receive


sub secret {
	validate_pos( @_,
		{ isa => 'Finance::Coinapult' }
	);
	my $self = shift;
	return $self->{env}->get_secret();
}

sub key {
	validate_pos( @_,
		{ isa => 'Finance::Coinapult' }
	);
	my $self = shift;
	return $self->{env}->get_key();
}

# below this line are private subs. please do not use them. they are subject
# to change at the whim of the developer, me. thx.
#

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
    # Config parameters get passed as a hashref
    config => {
      key    => 'asdkjakjad',   # This is not actually a real key
      secret => 'sdlkjdlkjasd', # This is not actually a real secret
    },

    # or ...
    json => 'a json string that includes a key and a secret',

    # or ...
    yaml_config => 'a yaml config file suitable for YAML::Accessor',

    # lastly, please pass an api base (or we will try to find a reasonable
    # default, but cannot guarantee It Will Work.
    api_base => 'http://api.coinapult.com/',
  );

  # And so on. See below for full list of api commands.
  $c->convert(
    inCurrency  => 'USD',
    outCurrency => 'BTC',
    amount      => 1,
  );

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
