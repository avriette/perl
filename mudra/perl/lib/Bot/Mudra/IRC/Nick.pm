package Bot::Mudra::IRC::Nick;

use v5.18;

use Params::Validate qw{ :all };

use base qw{ Class::Accessor };
use Bot::Mudra::IRC::Network;

our @ro_attribs = qw{ network };
our @rw_attribs = qw{ username realname mask };

sub new {
	my $package = shift;
	validate(
		@_, {
			username => { type => SCALAR, optional => 0 },
			realname => { type => SCALAR, optional => 1 },
			mask     => { type => SCALAR, optional => 1 },
			network  => { isa  => 'Bot::Mudra::IRC::Network', optional => 0 },
		},
	);

	my $args = { @_ };

	$package->follow_best_practice();
	$package->mk_ro_accessors( @ro_attribs );
	$package->mk_accessors( @rw_attribs );

	bless $args, $package;

	$args->_enmask();
	if (! $args->get_mask()) {
		$args->{mask} = 'no.mask.given';
		$logger->debug('no mask given');
	}

	return $args;
}

sub set_name {
	my $self = shift;
	$self->{username} = shift;
	$self->_enmask();
	return $self;
}

sub _enmask {
	my $self = shift;

	# No need to demask unless we're enmasked
	return undef unless $self->get_name() =~ /[!@]/;

	if (my ($nick, $mask) =( split /[!@]/, $self->get_name())[0,2]) {
		# If there is a mask defined, overwrite it. It shouldn't be there.
		$self->set_mask($mask);
		# We can't call set_nick() here because of recursion
		# XXX: Orthogonality
		$self->{name} = $nick;
		return $self;
	}
	return "pie";
}

sub _serialize {
  my $self = shift;
  validate( @_, { } );

  return { map { $_ => $self->{$_} } @attribs };
}

1;

=pod

=head1 NAME

Bot::Mudra::IRC::Nick

=head1 ABSTRACT

IRC nicks.

=head1 SYNOPSIS

	my $nick = Bot::Mudra::IRC::Nick->new(
		# a scalar
		nick     => "superman",

		# a network object
		network  => $channel,

		# optional, also a scalar
		mask     => 'secret.hideout.aq',
	);

	# Note that the mask will be automatically generated for you by the
	# constructor if the nick contains a '!'
	my $nick = Bot::Mudra::IRC::Nick->new(
		nick     => 'Superman!secret.hideout.aq',
		network  => $network,
	);

=head1 A NOTE ON ACCESSORS

Standard gettrs/settrs are available, but are readonly.

=head1 PARAMTERS

The C<network> attribute is NOT optional.

=head1 PRIVATE METHODS

C<_enmask> exists to separate a mask from a nick. So it would turn
superman!secret.hideout.aq into "superman" and "secret.hideout.aq".

=head1 AUTHOR

	jane avriette, jane@cpan.org

=cut
