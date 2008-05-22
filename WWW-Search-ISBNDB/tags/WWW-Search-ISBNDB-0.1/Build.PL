use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Search::ISBNDB',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@socklabs.com>',
    dist_version_from   => 'lib/WWW/Search/ISBNDB.pm',
    requires => {
        'Carp' => '1.03',
        'LWP::UserAgent' => '2.033',
        'Test::More' => '0.62',
        'WWW::Search' => '2.539',
        'XML::Simple' => '2.14',
    },
    add_to_cleanup      => [ 'WWW-Search-ISBNDB-*' ],
);

$builder->create_build_script();