use strict;
use Test::More qw(no_plan);
use WWW::Search;

my $search = WWW::Search->new('Feedster');
$search->native_query('world of warcraft linux');
my $result = $search->next_result;

while (my $result = $search->next_result()) {
	ok($result->title);
}
