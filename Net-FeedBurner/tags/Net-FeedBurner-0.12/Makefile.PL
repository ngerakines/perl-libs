use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::FeedBurner',
    AUTHOR              => 'Nick Gerakines <nick@gerakines.net>',
    VERSION_FROM        => 'lib/Net/FeedBurner.pm',
    ABSTRACT_FROM       => 'lib/Net/FeedBurner.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'English' => 0,
        'LWP::UserAgent' => 0,
        'Test::More' => 0,
        'Time::Format' => 0,
        'URI::Escape' => 0,
        'URI::Split' => 0,
        'XML::Simple' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-FeedBurner-*' },
);