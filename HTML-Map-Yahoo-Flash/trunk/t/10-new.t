#!perl

use strict;
use warnings;

use Test::More tests => 3;

use Data::Dumper;

use_ok( 'HTML::Map::Yahoo::Flash' );

my ($map);

{
	$map = HTML::Map::Yahoo::Flash->new( 'key' => 'test01' );
	ok($map, 'HTML::Map::Yahoo::Flash object created');
	isa_ok($map, 'HTML::Map::Yahoo::Flash', 'HTML::Map::Yahoo::Flash object created');
}
