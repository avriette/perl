package Finance::Coinapult::Environment;

use v5.18.0;

use Params::Validate qw{ :all };
use Carp qw{ confess cluck };
use base qw{ Class::Accessor };

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
		},
		api_base => {
			type     => SCALAR,
			optional => 1,
		},
	} );

	my ($json, $config, $yaml_config, $api_base) =
		@{ { @_ } }{ qw{ json config yaml_config api_base } };

	my $self = { };

	$self->{api_base} = $api_base ? $api_base :                              # \
		$ENV{COINAPULT_API_BASE} ? $ENV{COINAPULT_API_BASE} :                  # \
		confess "Coinapult API base needs to be defined in the environment ".  # \
			"or passed in to the constructor.";

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
	elsif ($yaml_config) {
		use YAML::Accessor;
		my $yc = YAML::Accessor->new(
			file     => $yaml_config,
			readonly => 1,
			damian   => 1,
		)
			or confess "Failed to read yaml config file.";

		$self->{yaml_config} = $yc;
		if ($self->{yaml_config}->get_key() and $self->{yaml_config}->get_secret()) {
			$self->{key}    = $self->{yaml_config}->get_key();
			$self->{secret} = $self->{yaml_config}->get_secret();
		}
		else {
			confess "YAML config parsed, but either key or secret (or both!) missing.";
		}
	}
	elsif (defined $ENV{COINAPULT_SECRET} and defined $ENV{COINAPULT_KEY}) {
		$self->{key}    = $ENV{COINAPULT_KEY};
		$self->{secret} = $ENV{COINAPULT_SECRET};
	}
	else {
		confess "Failed to parse configuration arguments or values. Try again.";
	}

	$class->follow_best_practice();
	$class->mk_ro_accessors( qw{ key secret api_base } );
	bless $self, $class;

}

"sic semper tyrannis";
