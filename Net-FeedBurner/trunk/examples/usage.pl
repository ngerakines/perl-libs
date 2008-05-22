#!perl

use strict;
use warnings;

use URI::Escape;
use URI::Split qw(uri_split uri_join);

use Net::FeedBurner;

my $user = '';
my $password = '';

my $fb = Net::FeedBurner->new('user' => $user, 'password' => $password);

# Get a list of my feeds.
my $feeds = $fb->find_feeds();

# Grab the first feed from the list.
my $feed = (sort keys %{$feeds})[0];

# Get information for a specific feed
my $feedinfo = $fb->get_feed($feed);

# Update the source url of the feed
my ($scheme, $auth, $path, $query, $frag) = uri_split(uri_unescape($feedinfo->{'url'}));
my $uri = $feedinfo->{'url'} . ($query ? '&' : '?') . 'fbtest=' . time;
$fb->modify_feed_source($feedinfo->{'id'}, $uri);

$fb->resync_feed($feed);

# Create a new feed and then delete immediately
my $t = substr time, -1, 3;
my $xml = <<"EOF";
<feed uri="dev-test/net-feedburner-$t" title="A Net::FeedBurner test feed">
	<source url="http://example.com/atom-index.xml" />
</feed>
EOF
my $newfeed = $fb->add_feed($xml);
$fb->delete_feed($newfeed->{'id'});
