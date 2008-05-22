use strict;
use Test::More tests => 4;
use WWW::Search;

my $search = WWW::Search->new('Feedster');
ok($search);
isa_ok($search, 'WWW::Search');
$search->native_query('gerakines');
my $result = $search->next_result;
ok($result);
isa_ok($result, 'WWW::SearchResult');
