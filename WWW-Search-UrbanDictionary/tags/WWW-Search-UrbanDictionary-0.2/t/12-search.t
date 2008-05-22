
use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Group;

use Module::Build;

my $build = Module::Build->current;

my $key = $build->args('key');

if (! $key) {
	skip_next_tests 4, 'An API key is required for the extended tests. Please get one at http://www.urbandictionary.com/api.php';
}

my ($search);

test 'Modules used ok' => sub {
	use_ok( 'WWW::Search' );
	use_ok( 'WWW::Search::UrbanDictionary' );
};

test 'Object creation' => sub {
	$search = WWW::Search->new('UrbanDictionary', 'key' => $key);
	ok($search, 'WWW::Search::UrbanDictionary object created -- good ');
	isa_ok($search, 'WWW::Search::UrbanDictionary', 'WWW::Search::UrbanDictionary object ref match -- good ');
};

test 'valid query test' => sub {
	$search->native_query('emo');
	my $result = $search->next_result;
	ok($result, 'got the first result -- good ');
	like(lc $result->{'word'}, qr/emo/, 'word matches -- good ');
	ok(defined $result->{'definition'}, 'definition exists -- good ');
};

test 'invalid query test' => sub {
	$search->native_query('urbandictionary test ' . time );
	my $result = $search->next_result;
	ok(! $result, 'Found nothing due to an invalid test -- good');
};
