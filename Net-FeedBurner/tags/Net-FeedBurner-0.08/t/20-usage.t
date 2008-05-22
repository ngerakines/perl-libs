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

plan tests => 10;

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

{
	ok($fb->resync_feed($feed), 'use resync_feed to have FB resync it -- good');
}

{
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
