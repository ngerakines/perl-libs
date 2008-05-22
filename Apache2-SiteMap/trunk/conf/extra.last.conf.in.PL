#!/usr/bin/env perl

use strict;
use warnings;

use IO::File();
# use Apache::TestRequest;

use FindBin qw($Bin);

my $f = new IO::File(">$ARGV[0]") or die $!;
$f->print(<<"EOF");

<IfModule mod_cgid.c>
     ScriptSock logs/cgisock
</IfModule>

<Perl>
    use Apache2::SiteMap;
</Perl>

<Location "/sitemap.xml">
    SetHandler modperl
    PerlHandler Apache2::SiteMap
    PerlSetVar SiteMapBase http://localhost/
    PerlSetVar SiteMapDir $Bin/../t/data/one/
</Location>

<Location "/music/sitemap.xml">
    SetHandler modperl
    PerlHandler Apache2::SiteMap
    PerlSetVar SiteMapBase http://localhost/music/
    PerlSetVar SiteMapDir $Bin/../t/data/two/
</Location>

<Location "/archives/sitemap.xml">
    SetHandler modperl
    PerlHandler Apache2::SiteMap
    PerlSetVar SiteMapBase http://localhost/archives/
    PerlSetVar SiteMapDir $Bin/../t/data/three/
</Location>

EOF

