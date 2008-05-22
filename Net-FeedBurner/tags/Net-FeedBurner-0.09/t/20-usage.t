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

plan tests => 11;

use_ok( 'Net::FeedBurner' );

my ($fb, $feeds, $feedinfo, $feed);

{ # Create a Net::FeedBurner object
	# NOTE: That secure (https) is not enabled by default
	$fb = Net::FeedBurner->new('user' => $user, 'password' => $password, 'secure' => 1);
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

{ # Get information on feed -- invalid feed id
	eval {
		$feedinfo = $fb->get_feed(time);
	};
	like($EVAL_ERROR, qr/^ERROR \d+/, 'error returned -- good');
}

{ # Update the source url of the feed
	my ($scheme, $auth, $path, $query, $frag) = uri_split(uri_unescape($feedinfo->{'url'}));
	my $uri = $feedinfo->{'url'} . ($query ? '&' : '?') . 'fbtest=' . time;
	ok($fb->modify_feed_source($feedinfo->{'id'}, $uri), 'update the source url for a feed -- good');
}

{ # Ask FeedBurner to resync the feed
	ok($fb->resync_feed($feed), 'use resync_feed to have FB resync it -- good');
}

{ # Create a new feed and then delete immediately
	my $t = substr time, -1, 3;
	my $xml = <<"EOF";
<feed uri="dev-test/net-feedburner-$t" title="A Net::FeedBurner test feed">
	<source url="http://example.com/atom-index.xml" />
</feed>
EOF
	ok(my $newfeed = $fb->add_feed($xml), 'create a new feed -- good');
	ok($newfeed->{'id'}, 'newly created feed has an id -- good');
	ok($fb->delete_feed($newfeed->{'id'}), 'delete our newly created feed -- good');
}
