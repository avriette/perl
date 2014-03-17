#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME              => 'Finance::Coinapult',
	VERSION           => '0.1',
	PREREQ_PM         => {
		'Params::Validate' => 0,
		'Scalar::Util'     => 0,
		'JSON'             => 0,
		'Class::Accessor'  => 0,
		'Crypt::Mac::HMAC' => 0,
	},
	'dist'            => {
		'COMPRESS' => 'gzip -9f',
		'SUFFIX'   => 'gz',
	},
	ABSTRACT => 'Perl package abstracting the Coinapult public API',
	AUTHOR   => 'Jane Avriette <jane@cpan.org>',
);
