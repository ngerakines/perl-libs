#!perl

use strict;
use warnings;

use Test::More;

use URI::Escape;
use URI::Split qw(uri_split uri_join);

use English;
use Module::Build;

my $build = Module::Build->current;

my $user = $build->args('user');
my $password = $build->args('password');

if (! $user || ! $password) { plan skip_all => 'No user/password set during build. Please assign a proper user and password to run the extended tests.'; }

plan tests => 7;

use_ok( 'Net::FeedBurner' );

my ($fb, $feeds, $feedinfo, $feed);

{
	$fb = Net::FeedBurner->new('user' => $user, 'password' => $password);
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{
	$feeds = $fb->find_feeds();
	ok($feeds, 'use find_feeds to get the first feed for a user -- good');
	$feed = (sort keys %{$feeds})[0];
}

{
	$feedinfo = $fb->get_feed($feed);
	ok($feedinfo, 'use get_feed to get the feeds info -- good');
}

{
	my ($scheme, $auth, $path, $query, $frag) = uri_split(uri_unescape($feedinfo->{'url'}));
	my $uri = $feedinfo->{'url'} . ($query ? '&' : '?') . 'fbtest=' . time;
	ok($fb->modify_feed_source($feedinfo->{'id'}, $uri), 'update the source url for a feed -- good');
}

SKIP: {
	skip 'This does not work for some reason.', 1;
	ok($fb->resync_feed($feed), 'use resync_feed to have FB resync it -- good');
}
