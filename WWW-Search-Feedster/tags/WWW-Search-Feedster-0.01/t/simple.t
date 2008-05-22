#!/usr/bin/perl -w

use strict;
use lib 'lib';
use Test::More qw(no_plan);
use_ok("WWW::Search");

my $search = WWW::Search->new('Feedster');
ok($search, "have WWW::Search::Feedster");

$search->native_query('world of warcraft linux');

my $result = $search->next_result;
ok($result);
