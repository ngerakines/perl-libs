use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Search::UrbanDictionary',
    license             => 'perl',
    dist_author         => 'Nick Gerakines <nick@socklabs.com>',
    dist_version_from   => 'lib/WWW/Search/UrbanDictionary.pm',
    requires => {
        'SOAP::Lite' => 0,
        'WWW::Search' => 0,
    },
	build_requires => {
		'XML::Simple' => 0,
		'Test::More' => 0,
		'Test::Group' => 0,
	},
	get_options => {
		'key' => { type  => '=s' },
	},
    add_to_cleanup      => [ 'WWW-Search-UrbanDictionary-*' ],
);

$builder->create_build_script();
