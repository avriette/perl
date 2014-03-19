#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME              => 'Finance::Coinapult',
	VERSION           => '0.1',
	PREREQ_PM         => {
		'Params::Validate'  => 0,
		'Scalar::Util'      => 0,
		'JSON::MaybeXS'     => 0,
		'Class::Accessor'   => 0,
		'Crypt::Mac::HMAC'  => 0,
		'Data::GUID'        => 0,
		'WWW::Curl::Simple' => 0,
		'HTTP::Request'     => 0,
		'HTTP::Headers'     => 0,
	},
	'dist'            => {
		'COMPRESS' => 'gzip -9f',
		'SUFFIX'   => 'gz',
	},
	ABSTRACT => 'Perl package abstracting the Coinapult public API',
	AUTHOR   => 'Jane Avriette <jane@cpan.org>',
);
