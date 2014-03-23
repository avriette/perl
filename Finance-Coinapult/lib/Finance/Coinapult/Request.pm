package Finance::Coinapult::Request;

use v5.12.0;
use base qw{ Class::Accessor };
use Params::Validate qw{ :all };

sub new {
	my $class = shift;
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

	my $self = { @_ };

	$class->follow_best_practice();
	$class->mk_accessors( keys %params );
	my $rv = {
		map {
			$_ => $self->{$_}
		} keys %params
	};
	# @{ $self }{sort keys %params} = @{ $self }{ sort keys %{ $self } };
	# return bless $self, $class;
	return bless $rv, $class;
}

"sic semper tyrannis";
