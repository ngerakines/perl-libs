#!/usr/bin/env perl

use strict;
use warnings;

use IO::File();
use Apache::TestRequest;

my $fakeurl = Apache::TestRequest::module2url('FakeDispatch');

my $f = new IO::File(">$ARGV[0]") or die $!;
$f->print(<<"EOF");

MaxClients 60

<IfModule mod_cgid.c>
     ScriptSock logs/cgisock
</IfModule>

<Perl>
    use Apache2::Const -compile => qw(OK DONE);
    use Apache2::Mogile::Dispatch;
    use FakeDispatch;
    use MogTracker;
    use MogOne;
    use MogTwo;
    use SocklabsDirector;
</Perl>

# -- httpd.conf
MogReproxyToken old_web
MogDirector SocklabsDirector
MogDomain socklabs
<MogTrackers>
  mog1 localhost:8531
</MogTrackers>
# <MogMemcaches>
#   memcache1 localhost:11211
# </MogMemcaches>

# PerlMapToStorageHandler Apache2::Const::OK
# <LocationMatch "^/">
#     SetHandler modperl
#     PerlHandler Apache2::Mogile::Dispatch
# </LocationMatch>

<LocationMatch "/FakeDispatch">
    SetHandler modperl
    PerlHandler FakeDispatch
</LocationMatch>

<VirtualHost setone>
    PerlMapToStorageHandler Apache2::Const::OK
    SetOutputFilter INCLUDES
    <LocationMatch "^/">
        SetHandler modperl
        PerlHandler Apache2::Mogile::Dispatch
    </LocationMatch>
</VirtualHost>

<VirtualHost MogTracker>
    PerlMapToStorageHandler Apache2::Const::OK
    PerlTransHandler MogTracker
</VirtualHost>

<VirtualHost MogOne>
    <LocationMatch "^/">
        SetHandler modperl
        PerlHandler MogOne
    </LocationMatch>
</VirtualHost>

<VirtualHost MogTwo>
    <LocationMatch "^/">
        SetHandler modperl
        PerlHandler MogTwo
    </LocationMatch>
</VirtualHost>

EOF
