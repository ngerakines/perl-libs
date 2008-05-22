#!perl

use Test::More tests => 5;

use Data::Dumper;
use_ok( 'Net::FeedBurner' );

my ($fb);

{
	$fb = Net::FeedBurner->new('user' => 'ngerakines', 'password' => 'asd123');
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{
	is($fb->urlbuilder('FindFeeds'), 'http://api.feedburner.com/management/1.0/FindFeeds?user=ngerakines&password=asd123', 'FindFeeds url match - good');
	is($fb->urlbuilder('GetFeed', 'id' => 1), 'http://api.feedburner.com/management/1.0/GetFeed?user=ngerakines&password=asd123&id=1', 'FindFeeds url match - good');
}
