#!perl

use strict;
use warnings;

use Time::Format qw(%time);

use Net::FeedBurner;

my $user = '';
my $password = '';

my $fbo = Net::FeedBurner->new('user' => $user, 'password' => $password);

# Get a list of my feeds
my $feeds = $fbo->find_feeds();

# Grab the first one in the list.
my $feed = (sort keys %{$feeds})[0];

# Fetch the feed info
my $feedinfo = $fbo->get_feed($feed);

# Get the general stats of a feed. The 'uri' is required.
my $stats = $fbo->feed_stats( 'uri' => $feedinfo->{'uri'});

# Get the general stats of a feed within a date range (past 7 days)
# $stats = $fbo->feed_stats(
#     'uri' => $feedinfo->{'uri'},
#     'dates' => {
#         $time{'yyyy-mm-dd', time - 86400 * 7} => $time{'yyyy-mm-dd'},
#     },
# );

# Get the general stats of a feed within a date range (past 2 days and then past 5th through 9th day)
# $stats = $fbo->feed_stats(
#     'uri' => $feedinfo->{'uri'},
#     'dates' => {
#         $time{'yyyy-mm-dd', time - 86400 * 2} => $time{'yyyy-mm-dd'},
#         $time{'yyyy-mm-dd', time - 86400 * 9} => $time{'yyyy-mm-dd', time - 86400 * 5},
#     },
# );

# Get some other stats of a feed
$stats = $fbo->feeditem_stats( 'uri' => $feedinfo->{'uri'} );

# Get some other stats of a feed in a date range (past 7 days)
# $stats = $fbo->feeditem_stats(
#     'uri' => $feedinfo->{'uri'},
#     'dates' => {
#         $time{'yyyy-mm-dd', time - 86400 * 7} => $time{'yyyy-mm-dd'},
#     },
# );

# Get some other stats of a feed in a date range (past 7 days)
# $stats = $fbo->feeditem_stats(
#     'uri' => $feedinfo->{'uri'},
#     'dates' => {
#         $time{'yyyy-mm-dd', time - 86400 * 2} => $time{'yyyy-mm-dd'},
#         $time{'yyyy-mm-dd', time - 86400 * 9} => $time{'yyyy-mm-dd', time - 86400 * 5},
#     },
# );

# Get some specific stats. The 'uri' is required.
$stats = $fbo->resyndication_stats( 'uri' => $feedinfo->{'uri'});


# Get some specific stats in a date range (past 7 days)
# my $stats = $fb->resyndication_stats(
#     'uri' => $feedinfo->{'uri'},
#     'dates' => {
#         $time{'yyyy-mm-dd', time - 86400 * 7} => $time{'yyyy-mm-dd'},
#     },
# );

# Get some specific stats in a date range (past 7 days)
# my $stats = $fb->resyndication_stats(
#     'uri' => $feedinfo->{'uri'},
#     'dates' => {
#         $time{'yyyy-mm-dd', time - 86400 * 2} => $time{'yyyy-mm-dd'},
#         $time{'yyyy-mm-dd', time - 86400 * 9} => $time{'yyyy-mm-dd', time - 86400 * 5},
#     },
# );

