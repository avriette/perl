#!/usr/bin/perl

use v5.18;

# A simple Rot13 'encryption' bot

use strict;
use warnings;
use POE qw(Component::IRC::State);

my $nickname = 'smurfette_' . $$;
my $ircname = 'semiautonomous smurfette process'
my $ircserver = 'irc.freenode.net';
my $port = 6667;

my @channels = ( '##mudra' );

# We create a new PoCo-IRC object and component.
my $irc = POE::Component::IRC::State->spawn(
	nick => $nickname,
	server => $ircserver,
	port => $port,
	ircname => $ircname,
) or die "Oh noooo! $!";

POE::Session->create(
	package_states => [
		main => [ qw(_default _start irc_001 irc_public) ],
	],
	heap => { irc => $irc },
);

$poe_kernel->run();

sub _start {
	my ($kernel, $heap) = @_[KERNEL, HEAP];

	# We get the session ID of the component from the object
	# and register and connect to the specified server.
	my $irc_session = $heap->{irc}->session_id();
	$kernel->post( $irc_session => register => 'all' );
	$kernel->post( $irc_session => connect => { } );
	return;
}

sub irc_001 {
	my ($kernel, $sender) = @_[KERNEL, SENDER];

	# Get the component's object at any time by accessing the heap of
	# the SENDER
	my $poco_object = $sender->get_heap();
	print "Connected to ", $poco_object->server_name(), "\n";

	# In any irc_* events SENDER will be the PoCo-IRC session
	$kernel->post( $sender => join => $_ ) for @channels;
	return;
}

sub irc_public {
	my ($kernel ,$sender, $who, $where, $what) = @_[KERNEL, SENDER, ARG0 .. ARG2];
	my $nick = ( split /!/, $who )[0];
	my $channel = $where->[0];
	my $poco_object = $sender->get_heap();

	if ( my ($rot13) = $what =~ /^rot13 (.+)/ ) {
		# Only operators can issue a rot13 command to us.
		return if !$poco_object->is_channel_operator( $channel, $nick );

		$rot13 =~ tr[a-zA-Z][n-za-mN-ZA-M];
		$kernel->post( $sender => privmsg => $channel => "$nick: $rot13" );
	}
	return;
}

# We registered for all events, this will produce some debug info.
sub _default {
	my ($event, $args) = @_[ARG0 .. $#_];
	my @output = ( "$event: " );

	for my $arg ( @$args ) {
		if (ref $arg  eq 'ARRAY') {
			push( @output, '[' . join(', ', @$arg ) . ']' );
		}
		else {
			push ( @output, "'$arg'" );
		}
	}
	print join ' ', @output, "\n";
	return 0;
}

exit 0;
