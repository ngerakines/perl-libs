#!perl

use strict;
use warnings;

use Test::More;

use English;
use Module::Build;

use Time::Format qw(%time);

my $build = Module::Build->current;

my $user = $build->args('user');
my $password = $build->args('password');

if (! $user || ! $password) { plan skip_all => 'No user/password set during build. Please assign a proper user and password to run the extended tests.'; }

plan tests => 18;

use_ok( 'Net::FeedBurner' );

my ($fb, $feeds, $feedinfo, $feed);

{ # Create a Net::FeedBurner object
	$fb = Net::FeedBurner->new('user' => $user, 'password' => $password);
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{ # Get a list of the feeds
	$feeds = $fb->find_feeds();
	ok($feeds, 'use find_feeds to get the first feed for a user -- good');
	$feed = (sort keys %{$feeds})[0];
}

{ # Get information for a specific feed
	$feedinfo = $fb->get_feed($feed);
	ok($feedinfo, 'use get_feed to get the feeds info -- good');
}

{ # Get the general stats of a feed
	my $stats = $fb->feed_stats( 'uri' => $feedinfo->{'uri'});
	ok($stats, 'get stats on a feed -- good');
}

{ # Get the general stats of a feed without providing uri
	eval {
		my $stats = $fb->feed_stats();
	};
	like($EVAL_ERROR, qr/You must submit a uri to continue./, 'error returned -- good');
}

{ # Get the general stats of a feed within a date range (past 7 days)
	my $stats = $fb->feed_stats(
		'uri' => $feedinfo->{'uri'},
		'dates' => {
			$time{'yyyy-mm-dd', time - 86400 * 7} => $time{'yyyy-mm-dd'},
		},
	);
	ok($stats, 'get stats on a feed -- good');
}

{ # Get the general stats of a feed within a date range (past 2 days and then past 5th through 9th day)
	my $stats = $fb->feed_stats(
		'uri' => $feedinfo->{'uri'},
		'dates' => {
			$time{'yyyy-mm-dd', time - 86400 * 2} => $time{'yyyy-mm-dd'},
			$time{'yyyy-mm-dd', time - 86400 * 9} => $time{'yyyy-mm-dd', time - 86400 * 5},
		},
	);
	ok($stats, 'get stats on a feed -- good');
}

{ # Get some other stats of a feed
	my $stats = $fb->feeditem_stats( 'uri' => $feedinfo->{'uri'} );
	ok($stats, 'get stats on a feed -- good');
}

{ # Get the general stats of a feed without providing uri
	eval {
		my $stats = $fb->feeditem_stats();
	};
	like($EVAL_ERROR, qr/You must submit a uri to continue./, 'error returned -- good');
}

SKIP: { # Get some other stats of a feed's specific item
	skip 'Need some real data to work with.', 1;
	my $stats = $fb->feeditem_stats(
		'uri' => $feedinfo->{'uri'},
		'item' => 'http://example.com/year/month/day/item_path.html',
	);
	ok($stats, 'get stats on a feed -- good');
}

{ # Get some other stats of a feed in a date range (past 7 days)
	my $stats = $fb->feeditem_stats(
		'uri' => $feedinfo->{'uri'},
		'dates' => {
			$time{'yyyy-mm-dd', time - 86400 * 7} => $time{'yyyy-mm-dd'},
		},
	);
	ok($stats, 'get stats on a feed -- good');
}

{ # Get some other stats of a feed in a date range (past 7 days)
	my $stats = $fb->feeditem_stats(
		'uri' => $feedinfo->{'uri'},
		'dates' => {
			$time{'yyyy-mm-dd', time - 86400 * 2} => $time{'yyyy-mm-dd'},
			$time{'yyyy-mm-dd', time - 86400 * 9} => $time{'yyyy-mm-dd', time - 86400 * 5},
		},
	);
	ok($stats, 'get stats on a feed -- good');
}

{ # Get some specific stats
	my $stats = $fb->resyndication_stats( 'uri' => $feedinfo->{'uri'});
	ok($stats, 'get stats on a feed -- good');
}

{ # Get the general stats of a feed without providing uri
	eval {
		my $stats = $fb->resyndication_stats();
	};
	like($EVAL_ERROR, qr/You must submit a uri to continue./, 'error returned -- good');
}

{ # Get some specific stats in a date range (past 7 days)
	my $stats = $fb->resyndication_stats(
		'uri' => $feedinfo->{'uri'},
		'dates' => {
			$time{'yyyy-mm-dd', time - 86400 * 7} => $time{'yyyy-mm-dd'},
		},
	);
	ok($stats, 'get stats on a feed -- good');
}

{ # Get some specific stats in a date range (past 7 days)
	my $stats = $fb->resyndication_stats(
		'uri' => $feedinfo->{'uri'},
		'dates' => {
			$time{'yyyy-mm-dd', time - 86400 * 2} => $time{'yyyy-mm-dd'},
			$time{'yyyy-mm-dd', time - 86400 * 9} => $time{'yyyy-mm-dd', time - 86400 * 5},
		},
	);
	ok($stats, 'get stats on a feed -- good');
}
