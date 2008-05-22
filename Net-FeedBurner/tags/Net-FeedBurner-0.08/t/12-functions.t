#!perl

use Test::More tests => 8;

use_ok( 'Net::FeedBurner' );

my ($fb);

{
	$fb = Net::FeedBurner->new('user' => 'testuser', 'password' => 'asd123');
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{
	is($fb->urlbuilder('FindFeeds'), 'http://api.feedburner.com/management/1.0/FindFeeds?user=testuser&password=asd123', 'FindFeeds url match - good');
	is($fb->urlbuilder('GetFeed', 'id' => 1), 'http://api.feedburner.com/management/1.0/GetFeed?user=testuser&password=asd123&id=1', 'GetFeed url match - good');
	is($fb->urlbuilder('AddFeed', 'feed' => '<feed />'), 'http://api.feedburner.com/management/1.0/AddFeed', 'AddFeed url match - good');
	is($fb->urlbuilder('DeleteFeed', id => 1), 'http://api.feedburner.com/management/1.0/DeleteFeed', 'DeleteFeed url match - good');
	is($fb->urlbuilder('ModifyFeed', 'feed' => '<feed />'), 'http://api.feedburner.com/management/1.0/ModifyFeed', 'ModifyFeed url match - good');
}
