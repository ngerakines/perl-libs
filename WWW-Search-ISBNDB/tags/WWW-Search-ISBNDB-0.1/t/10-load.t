#!perl -T

use Test::More tests => 4;

use_ok('WWW::Search');
use_ok('WWW::Search::ISBNDB');

my $search = WWW::Search->new('ISBNDB', key => 'BRW84XQS' );
ok( $search, 'object created' );

$search->native_query('born in blood');

my $result = $search->next_result;
ok($result, 'search results good');
