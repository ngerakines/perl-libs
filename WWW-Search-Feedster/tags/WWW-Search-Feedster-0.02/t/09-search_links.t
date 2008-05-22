use strict;
use Test::More qw(no_plan);
use WWW::Search;

my $search = WWW::Search->new('Feedster', category => 'links');
$search->native_query('http://www.feedster.com');

my $result = $search->next_result;

my $jcount = 0;
while (my $result = $search->next_result()) {
	$jcount++;
	ok($result->title);
}

ok($jcount > 1);
