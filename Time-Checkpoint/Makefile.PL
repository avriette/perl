use ExtUtils::MakeMaker;
use Time::HiRes;

WriteMakefile(
    'NAME'      => 'Time::Checkpoint',
    'PREREQ_PM'     => {
        'Params::Validate' => 0,
        'Test::More'       => 0,
        'common::sense'    => 0,
    },
    'dist' => { 
        'COMPRESS' => 'gzip -9f',
        'SUFFIX' => 'gz',
    },
    'VERSION'  => '0.35',
    'AUTHOR'   => 'Alex Avriette (alex@cpan.org)',
    'ABSTRACT' => 'Time-based checkpoints / deltas',
);

