use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Search::Feedster',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@socklabs.com>',
    dist_version_from   => 'lib/WWW/Search/Feedster.pm',
    requires => {
        'Carp'           => 0,
        'LWP::UserAgent' => 0,
        'Test::More'     => 0,
        'WWW::Search'    => 0,
        'XML::Simple'    => 0,
    },
    add_to_cleanup      => [ 'WWW-Search-Feedster-*' ],
);

$builder->create_build_script();