package FakeDispatch;

use strict;
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK);

use YAML::Syck;

sub handler {
    my ($r) = @_;

    my $what = $r->args;
    $r->content_type('text/plain');

    my %data = ( 'mogile' => 1 );
    if ($what eq 'domain=localhost') {
        $data{'mogile'} = 0;
        $data{'canonical_domain'} = 'localhost';
        $data{'domain'} = 'localhost';
    }
    if ($what eq 'domain=ngerakines.typepad.com') {
        $data{'mogile'} = 1;
        $data{'canonical_domain'} = 'localhost';
        $data{'domain'} = 'ngerakines.typepad.com';
        $data{'reproxy'} = 'http://blog.socklabs.com/';
    }
    if ($what eq 'domain=apache.perl.org') {
        $data{'mogile'} = 1;
        $data{'canonical_domain'} = 'apache-perl.typepad.com';
        $data{'domain'} = 'apache.perl.org';
    }
    $r->print(Dump(\%data));
    return Apache2::Const::OK; 
}

1;
