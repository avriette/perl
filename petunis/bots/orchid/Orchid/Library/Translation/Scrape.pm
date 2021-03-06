package Orchid::Library::Translation::Scrape;

=head1 NAME

Orchid::Library::Translation::Scrape

=cut

=head1 ABSTRACT

The "back end" of the Translation Library, provided with Orchid.
There are no user-serviceable parts inside.

=head1 THEORY OF OPERATION

This module creates two new POE Sessions, one of POCO::Client::HTTP,
and the other containing its inline states. These states are
C<requestTranslation>, C<doBabelfishTranslation>, and
C<getFrontPageLanguages>. Generally, we can expect that calls for
translations are made from the Orchid::Library::Translation module,
and passed via that module's C<translate()> method to the state
C<requestTranslation>. That method in turn should call
C<doBabelfishTranslation> when it has the data formatted for
translation and the http request has been made. C<requestTranslation>
will then do the "scraping" and yield the result back to the
O::L::Translation module.

=cut

use strict;
use warnings;

use HTML::TokeParser;
use Memoize;
use HTTP::Request::Common qw{ GET POST };
use POE qw{ Session Component::Client::HTTP };

our $babelfishUrl = qw{ http://babelfish.altavista.com/babelfish/tr };
our @languagesAvailable;
our %languageShortcuts;

=head1 SESSIONS 

=cut

=item wwwBabelfishScrape

This is our POE::Component::Client::HTTP session.

=cut

POE::Component::Client::HTTP -> spawn (
	Alias => 'wwwBabelfishScrape',
	Timeout => '180',
	# We have removed this because we do not expect large returns.
	# MaxSize => '4096', 
);

=item OrchidBabelfishScrape

This is the name of our "main" session, and contains the states we use
for making requests and parsing.

=cut

POE::Session -> create (
	inline_states => {
		
		# We aren't going to do any Initish stuff here since this module
		# doesn't really do anything that requires _start items.
		_start => sub {
			my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
			$kernel -> alias_set( 'OrchidBabelfishScrape' );
			# this serves as the initial "well being" test of altavista's 
			# availability, and also serves to get a list of languages for
			# use in translations.
			$kernel -> post( 
				wwwBabelfishScrape => request => getFrontpageLanguages => GET => $babelfishUrl 
			);
		},

=head1 STATES

=cut

=item requestTranslation 

We call requestTranslation when we have data we 
would like translated by altavista, and formatted by our parser.

	$kernel -> post( 
		'OrchidBabelfishScrape', 
		'requestTranslation', 
		$fromLang, 
		$toLang, 
		$inText 
	);

When incoming data has been formatted and prepared for altavista, the
data is then fed to this module's internal C<wwwBabelfishScrape> 
POCO::Client::HTTP session, with a target of C<doBabelfishTranslation>.
The parsing is done there.

=cut

		# {{{1
		requestTranslation => sub {
			my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];

			# There is a typo in POE::Session. find 'som '.
			my ( $fromLang, $toLang, $inText ) = @_[ ARG0 .. ARG2 ];
			$kernel -> post(
				wwwBabelfishScrape => request => doBabelfishTranslation => POST => [
					'doit' => 'done',
					'urltext' => $inText,
					'lp' => "$fromLang to $toLang",
					'Submit' => 'Translate',
					'enc' => 'utf8', # we might be able to frob this. irc doesnt like utf8.
				]
			); 

		}, # requestTranslation }}}1

=item doBabelfishTranslation

This state is called to perform the actual parsing after requestTranslation 
has made the http negotiation and formatted our inbound data. We're expecting
POCO::Client::HTTP to pass us a request object and a response object, per
the documentation for P::C::C::HTTP.

=cut

		# {{{1
		doBabelfishTranslation => sub { 
			my ($heap, $kernel, $request_packet, $response_packet) = 
				@_[HEAP, KERNEL, ARG0, ARG1];

			# These two are HTTP::Request and HTTP::Response objects
			my $request  = $request_packet->[0];
			my $response = $response_packet->[0];

			my $tokeParser;

			if (not $response -> is_success()) {
				# Our return variables need to be passed back to Orchid::Library::Translation
				# so that it can be returned via the $fish -> translate() method.
				return "A request error was generated by this request."; 
			}
			else {
				my $translatedPage = $response -> content();
				$tokeParser = HTML::TokeParser -> new( \$translatedPage );
			}
		
			# The syntax of this is somewhat icky, but we stole it from 
			# WWW::Babelfish, and Dan seems to like it icky.
			while (my $tag = $tokeParser -> get_tag('input')) {
				return @{$tag}[1]->{value} if @{$tag}[1]->{name} eq 'q';
			}

		}, # doBabelfishTranslation	}}}1

=item getFrontPageLanguages

Here, we make an initial connection to AltaVista.  This also serves as a 
viability test to make sure we can parse their data (the C<_start> state 
calls this state). If not, we die loudly. Normall called from 
Orchid::Library::Translation via a POE::Component::Client::HTTP session 

=cut

		# {{{1
		getFrontpageLanguages => sub {

			my ($heap, $kernel, $request_packet, $response_packet) = 
				@_[HEAP, KERNEL, ARG0, ARG1];

			# These two are HTTP::Request and HTTP::Response objects
			my $request  = $request_packet->[0];
			my $response = $response_packet->[0];
			
			if (not $response -> is_success()) {
				# Bad stuff happened on our first request.
				# We need to bail out. # XXX: Possibly just twiddle a "disable" bit.
				croak "Could not make initial connection to AltaVista for Babelfish.";
			}
			else {
				# The request was probably reasonable, lets see if we can grok
				# some languages out of it.
				my $frontPageContent = $response -> content();
				my $frontPage = HTML::TokeParser -> new(\$frontPageContent);

				# Stolen roughly from WWW::Babelfish.
				# This sort of stuff could probably be stored in the database pretty
				# easily. However, I think generating it dynamically allows us to make
				# sure we don't attempt to convert <-> a language that they don't support
				# anymore. Additionally, it allows us to check whether we can actually
				# reach them at all.
				my $conversionAvailable;
				my %langsFound;
				if ( $frontPage -> get_tag("select") ) {
					while ( $_ = $frontPage -> get_tag("option") ) {
						$conversionAvailable = $frontPage -> get_trimmed_text();
						$conversionAvailable =~ /(\S+)\sto\s(\S+)/;
						$langsFound{$1}++;
						$langsFound{$2}++;
					}
					@languagesAvailable = keys %langsFound;
					# We can't do any translating unless we have more than one language
					# available to us.
					croak "Babelfish found, but no languages available. Cannot continue."
						unless @languagesAvailable > 1;
					# We're making a hash here, so that we can use 'en' instead of 'English'
					%languageShortcuts = map { lc substr ($_, 0, 2) => $_ } @languagesAvailable;
				}
				else {
					croak "Initial connection to Babelfish made, frontpage useless.";
				}
			} # If response is good
		}, # getFrontpageLanguages }}}1
						
	} # inline_states
); 

sub new { 
  my $self = shift;
  my @args = @_;

	# Argument #1 is our html
	my $html = shift @args;

  return bless { 
    # Pieces of our object are constructed here.
		HTML => $html,
  }, $self;

}

sub lang_abbrev {
	my ($target) = (@_);
	return $languageShortcuts{$target} ? $languageShortcuts{$target} : $target;
}

1;

=head1 LICENSE

You should have received a license with this software. If you did
not, please remove this software entirely, and contact the author,
Alex Avriette - alex@posixnap.net.

=cut
