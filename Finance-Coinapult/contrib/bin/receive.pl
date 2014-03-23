use Finance::Coinapult;
use Finance::Coinapult::Environment;

# In theory, the empty constructor pulls from %ENV
my $c = Finance::Coinapult->new( );

my $cfr = $c->receive(
	currency => 'USD',
	method   => 'internal',
	amount   => 100,
);

use Data::Dumper; print Dumper $cfr;
