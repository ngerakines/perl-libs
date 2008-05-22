use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME	 => "WWW::Search::UrbanDictionary",
  VERSION_FROM => 'UrbanDictionary.pm',
  PREREQ_PM    =>  {
   'SOAP::Lite' => "0.60",
   'WWW::Search' => "2.35",
   'Test::More' => "0.01",
  },
  AUTHOR       => 'Nick Gerakines <nick@socklabs.com>',
  ABSTRACT     => 'WWW::Search::UrbanDictionary searches Urban Dictionary via SOAP'
);


sub MY::libscan {
  my $path = $_[1];
  return '' if $path =~ /\B\.svn\b/;
  return $path;
}
