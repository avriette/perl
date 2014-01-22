package Bot::Mudra::IRC::Chan;

use v5.18;

use Params::Validate qw{ :all };

use base qw{ Class::Accessor };

use Bot::Mudra::IRC::Network;

our @attribs = qw{ network name };

sub new {
	my $package = shift;
	validate( @_,
		{
			name   => { type => SCALAR },
			network => {
				isa => 'Bot::Mudra::IRC::Network',
				optional => 0,
			},
		}
	);

	my $args = { @_ };

	# Make sure the channel has proper sigil.
	if ($args->{name} !~ /^[#&]/) {
		$args->{name} = '#'.$args->{name};
	}

	$package->follow_best_practice();
	$package->mk_ro_accessors( @attribs );

	return bless $args, $package;
}

sub _serialize {
	my $self = shift;
	validate( @_, { } );

	return { map { $_ => $self->{$_} } @attribs };
}

1;

=pod

=head1 NAME

Bot::Mudra::IRC::Chan

=head1 ABSTRACT

Abstract channel into an object

=head1 SYNOPSIS

  my $channel = Bot::Mudra::IRC::Chan->new(
		# I will forgive you if you don't include a sigil; can be # or &
  	name    => '#itworks',
    
		# a Bot::Mudra::IRC::Server object
  	network => $network,    
  );

=head1 AUTHOR

  Jane Avriette, jane@cpan.org

=head1 BUGS

never.

=cut
