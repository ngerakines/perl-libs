use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'                => 'WWW::Wow::RealmStatus',
    'AUTHOR'              => 'Nick Gerakines <nick@gerakines.net>',
    'VERSION_FROM'        => 'lib/WWW/Wow/RealmStatus.pm',
    'ABSTRACT_FROM'       => 'lib/WWW/Wow/RealmStatus.pm',
    'PL_FILES'            => { },
    'PREREQ_PM'           => {
        'Test::More' => 0,
    },
    'dist'                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    'clean'               => { FILES => 'WWW-Wow-RealmStatus-*' },
);