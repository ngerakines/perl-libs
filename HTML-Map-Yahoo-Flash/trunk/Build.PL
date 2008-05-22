use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::Map::Yahoo::Flash',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@gerakines.net>',
    dist_version_from   => 'lib/HTML/Map/Yahoo/Flash.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HTML-Map-Yahoo-Flash-*' ],
);

$builder->create_build_script();
