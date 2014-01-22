package Bot::Mudra::Serialize;

use v5.18;

use Params::Validate qw{ :all };

use JSON;

sub serialize {
	my $package = shift;
	validate_pos( @_, 
		{
			type => SCALAR,   # this is the table
		},
		{
			# this needs to be an array of hashes
			type => ARRAYREF,
		},
		{
			# this needs to be an array of reasonable keys for the above hashes
			type => ARRAYREF,
			optional => 1,
		}
	);

	my $json = JSON->new();
	$json->indent()->space_before()->space_after();
	$json->allow_blessed();
	
	my ($table, $AoH, $keys) = (@_);

	return
		$json->encode( [ 
			map { 
				my $record = $_;
				$table => +{
					map { 
						$_ => $record->{$_}
					} @{ $keys }
				}
			} @{ $AoH }
		] ); 
}

sub deserialize {
	my ($self, $payload) = (@_);
	my $json = JSON->new();
	$json->indent()->space_before()->space_after();
	return $json->decode( $payload );
}

1;

