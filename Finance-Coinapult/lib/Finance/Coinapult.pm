package Finance::Coinapult;

use v5.18.0;

use Params::Validate qw{ :all };
use Crypt::Mac::HMAC qw{ hmac_hex };
use Finance::Coinapult::RequestFactory;
use Finance::Coinapult::Environment;
use Finance::Coinapult::Request;
use HTTP::Request::Common;
use WWW::Curl::Simple;
use HTTP::Headers;
use JSON::MaybeXS;
use Data::GUID;

sub new { # {{{ constructor
	my $class = shift;

	my %args = @_;  # this is validated in F::C::Environment
	my $self = { };
	$self->{env} = Finance::Coinapult::Environment->new( %args );
	
	$self->{methods} = { };

	bless $self, $class;

	$self->{methods}->{search} = $self->_mk_post(
		method_name    => 'search',
		uri            => '/t/search',
		reqd_arguments => [ qw{ callback } ],
		opt_arguments  => [ qw{ from to type transaction_id currency } ],
	);

	$self->{methods}->{receive} = $self->_mk_post(
		method_name    => 'receive',
		uri            => '/t/receive',
		reqd_arguments => [ qw{ method currency } ],
		opt_arguments  => [ qw{ outCurrency amount outAmount callback } ],
	);

	$self->{methods}->{send} = $self->_mk_post(
		method_name    => 'send',
		uri            => '/t/send',
		reqd_arguments => [ qw{ amount currency } ],
		opt_arguments  => [ qw{ callback } ],
	);

	$self->{methods}->{convert} = $self->_mk_post(
		method_name    => 'convert',
		uri            => '/t/convert',
		reqd_arguments => [ qw{ inCurrency outCurrency amount } ],
		opt_arguments  => [ qw{ callback } ],
	);

	return $self;

} # }}} constructor

sub secret { # {{{ secret
	validate_pos( @_,
		{ isa => 'Finance::Coinapult' }
	);
	my $self = shift;
	return $self->{env}->get_secret();
} # }}} secret

sub key { # {{{ key
	validate_pos( @_,
		{ isa => 'Finance::Coinapult' }
	);
	my $self = shift;
	return $self->{env}->get_key();
} # }}} key

# Below this line are internal subs.
#

sub _mk_post { # {{{ _mk_post
	my $self = shift;

	validate( @_, {
		method_name => {
			optional => 0,
			type     => SCALAR,
		},
		uri => {
			optional => 0,
			type     => SCALAR,
		},
		reqd_arguments => {
			optional => 0,
			type     => ARRAYREF,
		},
		opt_arguments  => {
			optional => 0,
			type     => ARRAYREF,
		},
	} );

	my %constructor_args = @_;

	my $new_method = sub {

		state $spec = {
			( map {
				$_ => {
					optional => 0,
					type     => SCALAR,
				}
			} $constructor_args{opt_arguments} ),
	
			( map {
				$_ => {
					optional => 1,
					type     => SCALAR
				}
			} $constructor_args{reqd_arguments} ),
		};
	
		validate( @_, $spec );

		my $args = { @_ };
	
		return Finance::Coinapult::RequestFactory->mk_request( $self,
			params => $args,
			uri    => $constructor_args{uri},
		);
		
	};

	return $new_method;

} # }}} _mk_post

sub _gen_soft_sub { # {{{
	my $self = shift;
	# Note from Class::Accessor that the syntax is:
	#  &{"${class}::$accessor_name"}
	# *{"${class}::$accessor_name"} = $self->make_ro_accessor($field);
	validate( @_, {
		'subname' => {
			type => SCALAR,
			optional => 0,
		},
		'package' => {
			type => SCALAR,
			optional => 1,
		},
	} );

	my $subname = { @_ }->{'subname'};
	my $package = { @_ }->{'package'} || __PACKAGE__;

	my $method = sub {
		return $self->{methods}->{$subname}->( @_ );
	};

	# This is a really messy soft-sub-ref. The quotes are for consistency
	# not prettiness.
	&{$package.'::'.$subname} = $method;

	# There's no real way we can verify this was successful here, so just return true.
	return $method;
} # }}} _gen_soft_sub

"sic semper tyrannis";

# jane@cpan.org // vim:tw=80:ts=2:noet

=pod

=head1 NAME

Finance::Coinapult

=head1 ABSTRACT

Public API access for Coinapult in perl. Ta-da!

=head1 SYNOPSIS

  use Finance::Coinapult;

  my $c = Finance::Coinapult->new(
    # Config parameters get passed as a hashref
    config => {
      key    => 'asdkjakjad',   # This is not actually a real key
      secret => 'sdlkjdlkjasd', # This is not actually a real secret
    },

    # or ...
    json => 'a json string that includes a key and a secret',

    # or ...
    yaml_config => 'a yaml config file suitable for YAML::Accessor',

    # lastly, please pass an api base (or we will try to find a reasonable
    # default, but cannot guarantee It Will Work).
    api_base => 'http://api.coinapult.com/',
  );

  # And so on. See below for full list of api commands.
  $c->convert(
    inCurrency  => 'USD',
    outCurrency => 'BTC',
    amount      => 1,
  );

=head1 DESCRIPTION

C<Finance::Coinapult> aims to create a shiny perl package for interfacing
with the Coinapult public API.

=head1 ACCESSORS

  # To return your secret
  $c->secret();

  # To return your API key
  $c->key();

=head1 METHODS

  $c->search(
    # required
    callback       => $callback_uri,

    # optional, but please choose one or more
    from           => $scalar,
    to             => $scalar,
    type           => $scalar,
    transaction_id => $scalar,
    currency       => $scalar,
  );

  $c->receive(
    # required
    method         => $scalar,
    currency       => $scalar,

    # optional
    outCurrency    => $scalar,
    amount         => $scalar,
    outAmount      => $scalar,
    callback       => $callback_uri,
  );

  $c->send(
    # required
    amount         => $scalar,
    currency       => $scalar,

    # optional
    callback       => $callback_uri,
  );

  $c->convert(
    # required
    inCurrency     => $scalar,
    outCurrency    => $scalar,
    amount         => $scalar,

    # optional
    callback       => $callback_uri,
  );

=head1 SEE ALSO

Stuff should go here.

=head1 BUGS

You may use the RT instance on L<https://rt.cpan.org/> to report bugs, or
simply report them to the author.

=head1 AUTHOR

Jane Avriette, E<lt>jane@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Jane Avriette & Coinapult

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
