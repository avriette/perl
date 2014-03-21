use Finance::Coinapult;
use Finance::Coinapult::Environment;

use v5.12.0;

use lib qw{ lib };

# In theory, the empty constructor pulls from %ENV
my $c = Finance::Coinapult->new( );
my $rates = $c->convert(
	inCurrency => 'USD',
	outCurrency => 'BTC',
	amount => '1',
);
if ($rates) {
	# use Data::Dumper; print Dumper $rates;
	say $rates->{data};
}
else {
	die "oh no";
}
