use 5.012004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Data::EnCase::HashList',
    VERSION_FROM      => 'lib/Data/EnCase/HashList.pm', # finds $VERSION
    PREREQ_PM         => {
			'File::Basename'   => 0,
			'File::Slurp'      => 0,
			'Class::Accessor'  => 0,
			'Params::Validate' => 0,
		},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Data/EnCase/HashList.pm', # retrieve abstract from module
       AUTHOR         => 'Jane A Avriette <jane@cpan.org>') : ()),
);
