#!/usr/bin/perl

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'WWW::Search::Odeo',
	license             => 'perl',
	dist_author         => 'Nick Gerakines <nick@socklabs.com>',
	dist_version_from   => 'lib/WWW/Search/Odeo.pm',
	requires => {
		'HTML::TreeBuilder' => 0,
		'URI' => 0,
		'URI::Escape' => 0,
		'WWW::Search' => 0,
		'WWW::SearchResult' => 0,
	},
	build_requires => {
		'Carp' => 0,
		'Data::Dumper' => 0,
		'Test::More' => 0,
	},
	add_to_cleanup      => [ 'WWW-Search-Odeo-*' ],
);

$builder->create_build_script();
