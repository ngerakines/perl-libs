use strict;
use Test::More tests => 1;
use WWW::Search;

my $search = WWW::Search->new('Feedster');
$search->native_query('world of warcraft linux');
my $result = $search->next_result;

ok($result);
