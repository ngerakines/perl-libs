#!perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::FeedBurner' );
}

diag( "Testing Net::FeedBurner $Net::FeedBurner::VERSION, Perl $], $^X" );
