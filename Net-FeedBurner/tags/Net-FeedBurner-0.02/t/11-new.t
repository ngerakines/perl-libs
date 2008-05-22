#!perl

use Test::More tests => 3;

use_ok( 'Net::FeedBurner' );

my ($fb);

{
	$fb = Net::FeedBurner->new();
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}
