#!perl

use Test::More tests => 22;

use_ok( 'Net::FeedBurner' );

my ($fb);

{
	$fb = Net::FeedBurner->new('user' => 'testuser', 'password' => 'asd123', 'secure' => 1);
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{ # Test some of the basic api calls
	is($fb->urlbuilder('FindFeeds'), 'https://api.feedburner.com/management/1.0/FindFeeds?password=asd123&user=testuser', 'FindFeeds url match - good');
	is($fb->urlbuilder('GetFeed', 'id' => 1), 'https://api.feedburner.com/management/1.0/GetFeed?id=1&password=asd123&user=testuser', 'GetFeed url match - good');
	is($fb->urlbuilder('AddFeed', 'feed' => '<feed />'), 'https://api.feedburner.com/management/1.0/AddFeed', 'AddFeed url match - good');
	is($fb->urlbuilder('DeleteFeed', id => 1), 'https://api.feedburner.com/management/1.0/DeleteFeed', 'DeleteFeed url match - good');
	is($fb->urlbuilder('ModifyFeed', 'feed' => '<feed />'), 'https://api.feedburner.com/management/1.0/ModifyFeed', 'ModifyFeed url match - good');
}

{ # Test some of the Awareness API calls
	is($fb->urlbuilder('GetFeedData', 'uri' => 'dev/test'), 'https://api.feedburner.com/awareness/1.0/GetFeedData?uri=dev/test', 'GetFeedData url match - good');
	is($fb->urlbuilder('GetItemData', 'uri' => 'dev/test'), 'https://api.feedburner.com/awareness/1.0/GetItemData?uri=dev/test', 'GetItemData url match - good');
	is($fb->urlbuilder('GetResyndicationData', 'uri' => 'dev/test'), 'https://api.feedburner.com/awareness/1.0/GetResyndicationData?uri=dev/test', 'GetResyndicationData url match - good');
}

{
	$fb = Net::FeedBurner->new('user' => 'testuser', 'password' => 'asd123', 'secure' => 1, 'locale' => 'jp');
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{ # Test some of the basic api calls
	is($fb->urlbuilder('FindFeeds'), 'https://api.feedburner.jp/management/1.0/FindFeeds?password=asd123&user=testuser', 'FindFeeds url match - good');
	is($fb->urlbuilder('GetFeed', 'id' => 1), 'https://api.feedburner.jp/management/1.0/GetFeed?id=1&password=asd123&user=testuser', 'GetFeed url match - good');
	is($fb->urlbuilder('AddFeed', 'feed' => '<feed />'), 'https://api.feedburner.jp/management/1.0/AddFeed', 'AddFeed url match - good');
	is($fb->urlbuilder('DeleteFeed', id => 1), 'https://api.feedburner.jp/management/1.0/DeleteFeed', 'DeleteFeed url match - good');
	is($fb->urlbuilder('ModifyFeed', 'feed' => '<feed />'), 'https://api.feedburner.jp/management/1.0/ModifyFeed', 'ModifyFeed url match - good');
}

{ # Test some of the Awareness API calls
	is($fb->urlbuilder('GetFeedData', 'uri' => 'dev/test'), 'https://api.feedburner.jp/awareness/1.0/GetFeedData?uri=dev/test', 'GetFeedData url match - good');
	is($fb->urlbuilder('GetItemData', 'uri' => 'dev/test'), 'https://api.feedburner.jp/awareness/1.0/GetItemData?uri=dev/test', 'GetItemData url match - good');
	is($fb->urlbuilder('GetResyndicationData', 'uri' => 'dev/test'), 'https://api.feedburner.jp/awareness/1.0/GetResyndicationData?uri=dev/test', 'GetResyndicationData url match - good');
}

{ # Test method availablity
	can_ok('Net::FeedBurner', qw/new init urlbuilder request find_feeds get_feed add_feed delete_feed modify_feed modify_feed_source resync_feed feed_stats feeditem_stats resyndication_stats/);
}
