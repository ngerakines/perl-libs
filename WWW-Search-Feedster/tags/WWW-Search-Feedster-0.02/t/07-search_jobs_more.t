use strict;
use Test::More qw(no_plan);
use WWW::Search;

my $search = WWW::Search->new('Feedster', category => 'jobs', location => 'california');
$search->native_query('perl');

my $result = $search->next_result;

my $jcount = 0;
while (my $result = $search->next_result()) {
	$jcount++;
	ok($result->title);
}

ok($jcount > 1);
