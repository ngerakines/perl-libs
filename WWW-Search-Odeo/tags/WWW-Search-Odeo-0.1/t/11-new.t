#!perl

use Data::Dumper;

use Test::More tests => 6;

use_ok( 'WWW::Search' );
use_ok( 'WWW::Search::Odeo' );

my ($search);

{
	$search = WWW::Search->new('Odeo');
	ok($search, 'WWW::Search::Odeo object created');
	isa_ok($search, 'WWW::Search::Odeo', 'WWW::Search::Odeo object created');
}

{
	$search->native_query('music');
	my $result = $search->next_result;
	ok($result, 'results found');
	isa_ok($result, 'WWW::SearchResult');	
}
