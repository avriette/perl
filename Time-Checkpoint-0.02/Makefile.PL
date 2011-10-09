# $Header$

use ExtUtils::MakeMaker;
use Time::HiRes;

WriteMakefile(
    'NAME'      => 'Time::Checkpoint',
    'PREREQ_PM'     => { 
        'Carp'             => 0,
        'Params::Validate' => 0,
        'Test::More'       => 0,
    },
    'dist' => { 
        'COMPRESS' => 'gzip -9f',
        'SUFFIX' => 'gz',
    },
    'AUTHOR' => 'Alex Avriette (alex@posixnap.net)',
    'ABSTRACT' => 'Time-based checkpoints / deltas',
);

