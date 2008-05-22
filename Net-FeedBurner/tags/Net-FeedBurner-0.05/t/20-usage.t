#!perl

use strict;
use warnings;

use Module::Build;
use Test::More;
use English;

eval { use XML::LibXML; };
if ( $EVAL_ERROR ) { plan skip_all => 'This set of tests requires XML::LibXML'; }

my $build = Module::Build->current;

my $user = $build->args('user');
my $password = $build->args('password');

if (! $user || ! $password) { plan skip_all => 'No user/password set during build. Please assign a proper user and password to run the extended tests.'; }

plan tests => 7;

use_ok( 'Net::FeedBurner' );

my ($fb, $feeds, $feedinfo, $feed);

{
	$fb = Net::FeedBurner->new('user' => $user, 'password' => $password);
	ok($fb, 'Net::FeedBurner object created');
	isa_ok($fb, 'Net::FeedBurner', 'Net::FeedBurner object created');
}

{
	$feeds = $fb->find_feeds();
	$feed = (sort keys %{$feeds})[0];
	diag "Using feed id $feed\n";
	ok($feeds);
}

{
	$feedinfo = $fb->get_feed($feed);
	ok($feedinfo);
}

{
	my ($feedxml);
	$feedxml = newxml($fb->{'rawxml'});
	ok($feedxml);
	ok($fb->modify_feed($feedxml));
}

sub newxml {
	my ($string) = @_;
	my $parser = XML::LibXML->new();
	my $doc = $parser->parse_string($string);
	my $docroot = $doc->documentElement();
	my ($feednode);
	if ($docroot->localname ne 'feed') {
		map { if ($_->localname && $_->localname eq 'feed') { $feednode = $_; } } $docroot->childNodes;
	} else {
		$feednode = $docroot;
	}
	my $sourcenode; map { if ($_->localname && $_->localname eq 'source') { $sourcenode = $_; } } $feednode->childNodes;
	my $urlattr; map { $urlattr = $_ } $sourcenode->attributes();
	my $newurl = $urlattr->getValue() . '?time=' . time;
	diag "Setting to new url $newurl\n";
	$urlattr->setValue($newurl);
	my $dom = XML::LibXML::Document->new();
	$dom->setDocumentElement( $feednode );
	return $dom->toString;
}

