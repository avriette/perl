package Finance::Coinapult::RequestFactory;

use v5.18.0;

use Crypt::Mac::HMAC qw{ hmac_hex };
use Params::Validate qw{ :all };
use Finance::Coinapult::Request;
use HTTP::Request::Common;
use WWW::Curl::Simple;
use HTTP::Headers;
use JSON::MaybeXS;
use Data::GUID;

sub mk_request {
	my $class = shift;
	my $c    = shift; # Finance::Coinapult object
	
	validate( @_, {
		uri => {
			optional => 0,
			type     => SCALAR,
		},
		params => {
			optional => 0,
			type     => HASHREF,
		},
	} );

	my ($uri_loc, $args) = @{ { @_ } }{ qw{ uri params } };

	$args->{timestamp} = time();

	# Just a unique (per 24h) identifier
	$args->{nonce} = Data::GUID->new()->as_string();

	# Package it, it has to be sorted
	my $sorted_payload = [ map { $_ => $args->{$_} } sort keys %{ $args } ];

	my $req = # {{{ POST
		POST $c->{env}->get_api_base().$uri_loc,
			'cpt-key'  => $c->key(),
			'cpt-hmac' => hmac_hex( 'SHA512',
				$c->secret(),
				JSON->new()->canonical()->encode( {
					# This is magical. Perl encodes this differently if these are
					# ints vs strings, so we force stringiness. It's an issue with
					# the backend that is preserved for backwards compatibility.
					map { $_ => "".$args->{$_} } sort keys %{ $args }
				} )
			),
			Content => $sorted_payload; # }}} POST

	my $r = Finance::Coinapult::Request->new(
		request => $req,
		payload => $sorted_payload,
		guid    => $args->{nonce},
		key     => $c->key(),
	);

	my $curl = WWW::Curl::Simple->new();
	my $content = $curl->request( $r->{request} )->content();

	# Note this is not blessed.
	#
	return {
		curl    => $curl,
		request => $r,
		data    => $content,
	};

} # }}} convert

"sic semper tyrannis";
