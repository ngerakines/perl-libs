#!perl

use Module::Build;
use Test::More;

my $build = Module::Build->current;

my $user = $build->args('user');
my $password = $build->args('password');

if ( $user && $password ) {
	plan tests => 5;
} else {
	plan skip_all => 'No user/password set during build. Please assign a proper user and password to run the extended tests.';
}

use_ok( 'Net::FeedBurner' );

my ($fb, $feeds, $feedinfo, $feed);

{
	$fb = Net::FeedBurner->new('user' => $user, 'password' => $password);
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{
	$feeds = $fb->find_feeds();
	$feed = (keys %{$feeds})[0];
	ok($feeds);
}

{
	$feedinfo = $fb->get_feed($feed);
	ok($feedinfo);
}

