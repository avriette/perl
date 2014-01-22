package Bot::Mudra::IRC::Network;

use v5.18;

use Params::Validate qw{ :all };
use base qw{ Class::Accessor };
our @attribs = qw{ id networkname };

sub new {
	my $package = shift;
	validate(
		@_, {
				networkname => { type => SCALAR },
				server      => { isa  => 'Bot::Mudra::IRC::Server', optional => 1 },
			},
		}
	);
	$package->follow_best_practice();
	$package->mk_ro_accessors( @attribs );

	my $args = bless { @_ }, $package;

	return $args;
}

1;
