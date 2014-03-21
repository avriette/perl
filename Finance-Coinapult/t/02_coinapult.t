use Test::More tests => 6;
BEGIN { use_ok('Finance::Coinapult') };
BEGIN { use_ok('Finance::Coinapult::Environment') };

use Finance::Coinapult::Environment;
use Finance::Coinapult;

# This should pull from the environment %ENV
my $environment = Finance::Coinapult::Environment->new( );
ok($environment);
ok($environment->get_key());
ok($environment->get_secret());

# In theory, the empty constructor pulls from %ENV
my $c = Finance::Coinapult->new( );
my $rates = $c->getRates(
	inCurrency => 'USD',
	outCurrency => 'BTC',
	amount => '1',
);
ok( $rates );
