package Finance::Coinapult::Environment;

use v5.18.0;

use Params::Validate qw{ :all };
use Carp qw{ confess cluck };
# use YAML::Accessor;

sub new {
	my $class = shift;
	validate( @_, {
		json => {
			type     => SCALAR,
			optional => 1,
		},
		config => {
			type     => HASHREF,
			optional => 1,
		},
		yaml_config => {
			type     => SCALAR,
			optional => 1,
		}
	} );

	my ($json, $config, $yaml_config) = %{ { @_ } }{ qw{ json config yaml_config } };

	my $self = { };

	if ($json) {
		use JSON::MaybeXS;
		my $decoded = decode_json($json);
		if ($decoded->{secret} and $decoded->{key}) {
			$self->{secret} = $decoded->{secret};
			$self->{key}    = $decoded->{key};
		}
		else {
			confess "This json seems to be missing either the key or secret.";
		}
	}
	elsif ($config) {
		if ($config->{secret} and $config->{key}) {
			$self->{secret} = $config->{secret};
			$self->{key}    = $config->{key};
		}
		else {
			confess "The supplied hashref does not include the requisite keys.";
		}
}

"sic semper tyrannis";
