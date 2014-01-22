package BAH::Overseer::Medusa::Server;

use common::sense;

use Params::Validate qw{ :all };
use BAH::Overseer::Config qw{ $logger };
use BAH::Overseer::Medusa::Network;
use Net::Ping;
use Net::DNS;
use base qw{ Class::Accessor };
our @attribs = qw{ hostname active network id port ssl };
our $cfg    = BAH::Overseer::Config->new_cached( );
our $logger = $cfg->{logger};
our $dbconn = $cfg->{dbconn};

sub new {
	my $package = shift;
	validate(
		@_, {
			hostname => {
				type => SCALAR
			}, 
			active   => {
				type     => SCALAR,
				regex    => qr/(true|false)/i,
				optional => 1,
			},
			network  => {
				type => SCALAR,
				optional => 1,
			},
			port     => {
				optional => 1,
			},
			ssl      => {
				optional => 1,
			},
			id       => {
				type     => SCALAR,
				optional => 1,
				regex    => qr/[0-9]+/,
			},
		}
	);
	
	$package->follow_best_practice();
	$package->mk_ro_accessors( @attribs );
	
	my $args = { @_ };
	my %obj = ( );

	# if a network name wasn't defined, set it to the hostname
	# this conflicts heavily with things that try to access the 
	# once scalar network...need to see if this is what was meant
	if (not defined $args->{network}) {
		$obj{network} = BAH::Overseer::Medusa::Network->new( networkname => $args->{hostname} );
	}
	else {
		$obj{network} = BAH::Overseer::Medusa::Network->new( networkname => $args->{network} );
	}

	$obj{hostname} = $args->{hostname};
	$obj{id}       = $args->{id};
	$obj{port}     = $args->{port} ? $args->{port} : 6667;
	$obj{ssl}      = $args->{ssl} ? $args->{ssl} : 0;
	
	my $self = bless \%obj, $package;

        # grab the first valid IP from hostname resolution
        # settling for the first one that responds to ping...not the best solution, but it'll do (for now)

        my $res = Net::DNS::Resolver->new;

        # Perform a lookup, using the searchlist if appropriate.
        my $dnsanswer = $res->search($self->get_hostname);
        if ($dnsanswer) {
            my $p = Net::Ping->new("tcp");
            $p->port_number(6667);
            foreach my $rr ($dnsanswer->answer) {
                next unless $rr->type eq "A";
                print "pinging " . $rr->address . "\n";
                
                if ($p->ping($rr->address), 1) {
                   # print "Successful ping on " . $rr->address . ", using as IP for " . $self->get_hostname() . "\n";

                    # From this point onward, networkname will always be either a hostname or an IP. No more custom network names.
                    $self->{network}->{networkname} = $self->get_hostname();
                    $self->{hostname} = $rr->address;
                    last;
                }
                else {
                    #print "Unsuccessful ping.\n";
                }
            }
            #print "Using " . $self->get_hostname . " to connect to " . $self->get_network()->get_networkname() . "\n";
            $p->close();
        }

	my $answer = $dbconn->run(fixup =>
		sub {
			my $sth = $_->prepare(q/
				select new_server(?, ?);
			/);
			$sth->execute( $self->get_hostname(), $self->get_network()->get_networkname() );
			my ($sid) = map { @{ $_ } } @{ $sth->fetchall_arrayref() };
			# If negative, the hostname already existed and had an sid.
			if ($sid > 0) {
				$logger->info("new server noticed: ".$self->get_hostname()." on network ".
					$self->get_network()->get_networkname()." and inserted");
			}
			else {
				$logger->debug("have already seen this server. set server id to " . $sid);
			}
			return $sid;
		}
	);
	
	# If the sid returned was negative, server already exists in db
	# Simply take the absolute value for future use 
	$self->{id} = $answer ?
		$answer * -1 :
		$answer;
	
	# Later, we can make sure that everything in this object actually matches with the db. 
	
	# The network might not be defined, but that was taken care of earlier.
	# there's not actually a network pkey in the db...need to figure out what was meant.
	# Server ID used for network ID for now.
	$self->{network}->{id} = $self->{id};
	
	return $self;
}

sub _serialize {
	my $self = shift;
	validate( @_, { } );
	return { map { $_ => $self->{$_} } @attribs };
}

1;

=pod

=head1 NAME

BAH::Overseer::Medusa::Server

=head1 ABSTRACT

Simple class to define a server record in the database.

=head1 SYNOPSIS

  my $server = BAH::Overseer::Medusa::Server->new(
  	hostname     => 'irc.hostname.net',
  	network      => 'hostNet', # optional parameter
  	id           => 42, # optional parameter
  );
    
=head1 DETAILS

The "server" object is more complicated than it appears. In the database,
the server has many more attributes than are simply defined in the constructor.
A server has values for:

  whether it is 'active' or not (boolean)
  its hostname (a scalar)
  its unique id (an integer)
  its network name (a scalar)
  
Remember that databases are strongly classed and an integer is an I<integer>, not
a simple scalar value.

=head1 METHODS

All these methods are considered not-user-friendly and are intended to be used 
internally by the API. If you must use them, be cautious.

C<_servername_to_serverid>

	my $id = $server->_servername_to_serverid(
		servername => $server->get_hostname()
	);

This is useful for database operations. It is a direct call to a plpgsql function.
Will return undef if it cannot resolve the serverid.

C<_serverid_to_name>

	my $name = $server->_serverid_to_name( serverid => $server->get_id() );
	
Returns the name of the server if all you have is the ID. This is a direct call
to a plpgsql function, and is used INTERNALLY. Will return undef if it can't
resolve the name.

C<_isa_new_server>

	$server->_isa_new_server();
	
Always returns true. This is used if the server hasn't been seen before. It's added
to the servers table.

C<_serverid_to_network_name>

	my $nname = $server->_serverid_to_network_name( serverid => $server->get_id() );
	
This might be useful for logging messages. It is a direct call to a plpgsql function.
Will return undef if it can't resolve the id to a network name.

=head1 AUTHOR

 Alex J. Avriette
 (avriette_alex@bah.com)
 
=head1 BUGS

Maybe.

=cut
