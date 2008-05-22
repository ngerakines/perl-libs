#! /usr/bin/perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Yahoo::KeywordExtractor' );
}

diag( "Testing WWW::Yahoo::KeywordExtractor $WWW::Yahoo::KeywordExtractor::VERSION, Perl $], $^X" );
