use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Net::FeedBurner',
	license             => 'perl',
	dist_author         => 'Nick Gerakines <nick@socklabs.com>',
	dist_version_from   => 'lib/Net/FeedBurner.pm',
	build_requires => {
		'Test::More' => 0,
		'XML::Simple' => 0,
		'LWP::UserAgent' => 0,
	},
	add_to_cleanup      => [ 'Net-FeedBurner-*' ],
	get_options => {
		'user' => { type  => '=s' },
		'password' => { type  => '=s' },
	},
);

$builder->create_build_script();
