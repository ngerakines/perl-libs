use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Wow::RealmStatus',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@gerakines.net>',
    dist_version_from   => 'lib/WWW/Wow/RealmStatus.pm',
    build_requires => {
        'Test::More' => 0,
        'LWP::UserAgent' => 0,
        'Cache::Memcached' => 0,
        'XML::Descent' => 0,
        'JSON::XS' => 0,
    },
    add_to_cleanup      => [ 'WWW-Wow-RealmStatus-*' ],
);

$builder->create_build_script();
