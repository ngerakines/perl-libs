use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::Adsense',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@gerakines.net>',
    dist_version_from   => 'lib/HTML/Adsense.pm',
    build_requires => {
        'Test::More' => 0,
        'Class::Accessor' => 0,
    },
    add_to_cleanup      => [ 'HTML-Adsense-*' ],
);

$builder->create_build_script();
