package MogTwo;

use strict;
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK);

sub handler {
    my ($r) = @_;
    if ($r->header_only()) { return Apache2::Const::OK; }

    $r->content_type('text/plain');

    if ($r->uri eq '/f0/000/0000/00000.fid') {
        $r->print(<<'EOF');

There is no place like home.

<!--#include virtual="/home/" -->

EOF
   }

    if ($r->uri eq '/f0/000/0000/00001.fid') {
        $r->print(<<'EOF');

Ok, so maybe there is ...

EOF
   }

    return Apache2::Const::OK; 
}


1;
