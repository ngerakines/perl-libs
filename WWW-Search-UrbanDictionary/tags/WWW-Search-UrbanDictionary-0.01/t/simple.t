#!/usr/bin/perl -w

use strict;
use lib 'lib';
use Test::More qw(no_plan);
use_ok("WWW::Search");

# unfortunately we can't test anything without a Google API license
# key, oh well

# If you do have a key, comment out the "__END__" and put your key
# where it says "XXXX". Then run "make test"

__END__

my $key = "XXXX";
my $search = WWW::Search->new('UrbanDictionary', key => $key);
ok($search, "have WWW::Search::UrbanDictionaryobject");

$search->native_query("emo");

my $result = $search->next_result;
ok($result);
like($result->word, qr/emo/);
ok(defined $result->definition)
