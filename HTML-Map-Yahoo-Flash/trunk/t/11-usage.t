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

{
    $map->add_marker( 'point' => [ 37.3913750, -122.0716020 ], 'title' => 'Home', 'description' => 'This is my house.' );
    $map->add_marker( 'point' => [ 38.3913750, -123.0716020 ], 'title' => 'Office', 'description' => 'This is my office.' );
}
