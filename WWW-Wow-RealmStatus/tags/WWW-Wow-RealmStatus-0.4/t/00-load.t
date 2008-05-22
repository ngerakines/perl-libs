#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Wow::RealmStatus' );
}

diag( "Testing WWW::Wow::RealmStatus $WWW::Wow::RealmStatus::VERSION, Perl $], $^X" );
