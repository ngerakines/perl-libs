use strict;
use Test::More tests => 2;

use_ok("WWW::Search");

my $search = WWW::Search->new('Feedster');
ok($search, "WWW::Search::Feedster Loaded");
