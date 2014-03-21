package Finance::Coinapult;

use 5.12.0;

use Params::Validate qw{ :all };
use Crypt::Mac::HMAC qw{ hmac_hex };
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
sub convert {
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
				_sort_encode_json( $sorted_payload )
			),
			Content => $sorted_payload; # POST

	warn $req->as_string();

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

}

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

# Because these have to be sorted by alpha, we have a utility sub to do it
# for us rather than replicate code.
#
sub _sort_encode_json {
	validate_pos( @_, { type => ARRAYREF } );
	my $href = shift;
	my $json = JSON->new()->canonical()->encode( $href );
	return $json;
}

# Turn the return into an aref. What happens after that is up to you.
#
sub _demarshal {
	# amount=1&inCurrency=USD&nonce=8FDF8970-B056-11E3-AB3B-9724B38F7484&outCurrency=BTC&timestamp=1395337157

	my $string = shift;
	my @pairs = [ split '&', $string ];

	# Returns an aref because we use it elsewhere for payloads. Otherwise this 
	# looks a lot like a hash.
	#
	return [ map { split '=', $_ } @pairs ];
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
  $c->getRates(
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
