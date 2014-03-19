use Test::More tests => 5;
BEGIN { use_ok('Finance::Coinapult') };
BEGIN { use_ok('Finance::Coinapult::Environment') };

use Finance::Coinapult::Environment;
use Finance::Coinapult;

# This should pull from the environment %ENV
my $environment = Finance::Coinapult::Environment->new( );
ok($environment);
ok($environment->get_key());
ok($environment->get_secret());
