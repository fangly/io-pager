use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'              => 'IO::Pager',
    'VERSION_FROM'      => 'lib/IO/Pager.pm', # finds $VERSION
    'BUILD_REQUIRES'    => {
       'Test::More'     => 0,
    },
    'PREREQ_PM'         => {
       'Env'            => 0,
       'File::Spec'     => 0,
       'Tie::Handle'    => 0,
    },
    'META_MERGE' => { recommends => {
       'File::Which'    => 0,
    }},
    ($] >= 5.005 ?  # Add these new keywords supported since 5.005
       (ABSTRACT_FROM    => 'lib/IO/Pager.pm', # retrieve abstract from module
        AUTHOR           => 'Jerrad Pierce <belg4mit@mit.edu>') : ()),
);
