package Finance::Coinapult::Request;

use v5.12.0;
use Class::Accessor;
use Params::Validate qw{ :all };

sub new {
	my $class = shift;
	my $self = { };
	my %params = (
		header => {
			optional => 1,
			type     => OBJECT,
		},
		request => {
			optional => 0,
			type     => OBJECT,
		},
		payload => {
			optional => 0,
			type     => OBJECT | ARRAYREF,
		},
		guid    => {
			optional => 0,
			type     => OBJECT | SCALAR,
		},
		key     => {
			optional => 1,
			type     => SCALAR,
		},
	);
	validate( @_, { %params } );

	$class->follow_best_practice();
	$class->mk_accessors( keys %params );
	return bless $self, $class;
}

"sic semper tyrannis";
