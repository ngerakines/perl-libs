use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME	 => "WWW::Search::Feedster",
	VERSION_FROM => 'Feedster.pm',
	PREREQ_PM    =>  {
		'XML::RSS::LibXML' => "0.05",
		'WWW::Search' => "2.35",
		'Test::More' => "0.01",
	},
	AUTHOR       => 'Nick Gerakines <nick@socklabs.com>',
	ABSTRACT     => 'Search feeds from Feedster'
);


sub MY::libscan {
	my $path = $_[1];
	return '' if $path =~ /\B\.svn\b/;
	return $path;
}
