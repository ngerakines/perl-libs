use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Yahoo::KeywordExtractor',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@socklabs.com>',
    dist_version_from   => 'lib/WWW/Yahoo/KeywordExtractor.pm',
    build_requires => {
		'Digest::MD5' => 0,
		'LWP::UserAgent' => 0,
		'URI::Escape' => 0,
        'Test::More' => 0,
		'XML::Simple' => 0,
    },
    add_to_cleanup      => [ 'WWW-Yahoo-KeywordExtractor-*' ],
);

$builder->create_build_script();
