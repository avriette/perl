#!/usr/bin/perl

use v5.18;

use POE qw{
	Component::IRC::State
	Component::IRC::Plugin::NickServID
	Component::IRC::Plugin::AutoJoin
	Component::IRC::Plugin::ISupport
	Component::IRC::Plugin::Logger
	Component::IRC::Plugin::CTCP
	Component::IRC
	Session
} ;

use YAML::Accessor; # {{{

my $yc = YAML::Accessor->new(
	file => 'mudra.ycf',
	autocommit => 1,
	readonly => 0,
	damian => 1,
) or die "Sorry fluffy, the config isn't there.";

=cut

control :
  server   : irc.tripsit.me
  port     : 6697
  ssl      : yes
  realname : This Gigantic Robot Kills
  authnick : mudra
  authpass : #####
  nick     : mudra
  ircname  : mudra

=cut

# }}}

my $irc = POE::Component::IRC::State->spawn(
	server   => $yc->get_control()->get_server(),
	port     => $yc->get_control()->get_port(),
	ssl      => $yc->get_control()->get_ssl(),
	username => $yc->get_control()->get_realname(),
	ircname  => $yc->get_control()->get_ircname(),
	nick     => $yc->get_control()->get_nick(),
);

die "failed to instantiate irc object" unless $irc;

$irc->plugin_add( 'NickServID', # {{{
	POE::Component::IRC::Plugin::NickServID->new(
		Password => $yc->get_control()->get_authpass(),
	),
); # }}}

$irc->plugin_add( 'AutoJoin', # {{{
	POE::Component::IRC::Plugin::AutoJoin->new(
		Channels => $yc->get_control()->get_control_channel()
	),
); # }}}

$irc->plugin_add( 'ISupport', # {{{
	POE::Component::IRC::Plugin::ISupport->new()
); # }}}

POE::Session->create(
	inline_states => {
		_start => sub { say "started main session" },
	},

	heap => {
		irc => $irc,
	},

);

POE::Kernel->run();
exit;
