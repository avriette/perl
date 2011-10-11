#!/usr/bin/perl

use warnings; 
use strict;
use ExtUtils::MakeMaker;

# This is a temporary fix suggested by David Golden
# and cpan-testers@
exit 0 if $ENV{AUTOMATED_TESTING};

WriteMakefile(
	NAME         => 'Net::TDMA',
	VERSION      => '0.2',
#	VERSION_FROM => 'lib/TDMA.pm', # (this is an svn thing)
	dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
	AUTHOR       => 'Alex J. Avriette (alex@cpan.org)',
	ABSTRACT     => 'Teaching Implementation of TDMA networking protocol',
);
