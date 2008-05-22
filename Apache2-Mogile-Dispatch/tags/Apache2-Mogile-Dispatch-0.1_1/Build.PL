use strict;
use warnings;

use Module::Build;
use Apache::TestMB;

my $build_pkg = eval { require Apache::TestMB } ? 'Apache::TestMB' : 'Module::Build';

my $builder = $build_pkg->new(
    module_name         => 'Apache2::Mogile::Dispatch',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@socklabs.com>',
    dist_version_from   => 'lib/Apache2/Mogile/Dispatch.pm',
    requires => {
        'LWP::UserAgent' => 0,
        'Cache::Memcached' => 0,
        'MogileFS' => 0,
        'English' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'Apache::Test' => 0,
        'Test::Group' => 0,
        'YAML::Syck' => 0,
    },
    add_to_cleanup      => [ 'Apache2-Mogile-Dispatch-*' ],
    recursive_test_files => 1,
    create_readme => 0,
    test_files => [qw/t/],
    get_options => { },
    PL_files => {
        'conf/httpd.conf.in.PL' => 'conf/httpd.conf.in',
        'conf/extra.last.conf.in.PL' => 't/conf/extra.last.conf.in',
    },
);

$builder->create_build_script();
