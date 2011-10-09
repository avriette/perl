use Test::More qw{ no_plan };

use_ok( 'Time::Checkpoint' );

my $t = Time::Checkpoint->new();

ok( $t, "object created" );
ok( ref $t eq 'Time::Checkpoint', "object is what we expected" );

# aja // vim:tw=80:ts=2:noet:syntax=perl
