package Bot::Mudra::IRC::Message;

use v5.18;

use Params::Validate qw{ :all };

use base qw{ Class::Accessor };
# note: privmsg can go to a #channel or to a user. so 'target' here is also 'channel'
our @attribs = qw{ message timestamp target sender };

sub new {
	my $package = shift;
	validate( @_, {
		map { $_ => {
			type => SCALAR,
			optional => 0,
		} } @attribs
	} );

	my $args = { @_ };

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

Bot::Mudra::IRC::Message

=head1 ABSTRACT

A wrapper for "privmsg" messages from IRC.

=head1 SYNOPSIS

  my $msg = Bot::Mudra::IRC::Message->new(
    message   => "a witty message",

		# all time in mudra is assumed to be utc
    timestamp => time(),

		# this should be a user object
    sender    => $sender,

		# Either of these will work
    target    => $user,
    target    => $channel,
  );

  # suitable for serializing this object.
  my $json = $msg->serialize();

=head1 AUTHOR

	jane avriette, jane@cpan.org

=cut
