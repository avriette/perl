#!/usr/bin/perl

use 5.18.0;

use WWW::Curl::Simple;
use HTTP::Request::Common;
use HTTP::Headers;
use JSON qw{ encode_json };
use Crypt::Mac::HMAC qw{ hmac_hex };
use Data::GUID;

use JSON::MaybeXS; 
# Note that mst says JSON::MaybeXS is rage-driven development(tm)

use constant RATES_URL   => 'http://api.coinapult.com/api/getRates';
use constant CONVERT_URL => 'http://api.coinapult.com/api/t/convert';

my $curl = WWW::Curl::Simple->new();

say "fetching rates...";
say $curl->get( RATES_URL )->decoded_content();

my %params = (
	timestamp   => (sprintf '%d', time()),
	nonce       => Data::GUID->new()->as_string(),
	inCurrency  => 'BTC',
	outCurrency => 'USD',
	amount      => '1',
);

my $sorted_keys = [
	# GP tells us the keys to the dict must be sorted.
	map { $_ => $params{$_} } sort keys %params
];

my $jsonified_params = encode_json {
	# GP tells us the keys to the dict must be sorted.
	map { $_ => $params{$_} } sort keys %params
};
$jsonified_params = JSON->new->canonical->encode(\%params);
say "json params => $jsonified_params";

my $hdr = HTTP::Headers->new(
	'cpt-key' => KEY,
	'cpt-hmac' => hmac_hex( 'SHA512', SECRET, $jsonified_params ),
);
my $req = POST CONVERT_URL,
	'cpt-key' => KEY,
	'cpt-hmac' => hmac_hex( 'SHA512', SECRET, $jsonified_params ),
	Content => $sorted_keys;

say "testing api key...";
say "request =====>";
say $req->as_string();
say "return =====>";
say $curl->request( $req )->content();
