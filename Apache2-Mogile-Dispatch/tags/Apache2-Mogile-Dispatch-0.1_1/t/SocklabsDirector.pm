package SocklabsDirector;

use strict;
use warnings;

use APR::Table ();
use APR::SockAddr ();
use Apache2::RequestRec ();
use Apache2::RequestUtil ();
use Apache2::Connection ();
use Apache2::Filter ();
use Apache2::RequestRec ();
use Apache2::Module;
use Apache2::CmdParms ();
use Apache2::Directive ();
use Apache2::Log ();
use Apache2::URI ();
use Apache2::Const -compile => qw(DECLINED OK OR_ALL RSRC_CONF TAKE1 RAW_ARGS NO_ARGS DONE NOT_FOUND);

use LWP::UserAgent;
use YAML::Syck;

use constant FAKEDIRECTOR_URL => 'http://localhost:8529/FakeDispatch';

sub memcache_key {
    my ($self, $r, $config) = @_;
    return $r->hostname;
}

sub get_direction {
    my ($self, $r, $config) = @_;
    my $ua = LWP::UserAgent->new;
    my $url = FAKEDIRECTOR_URL . '?domain=' . $r->hostname;
    my $response = $ua->get($url);
    if ($response->is_success) {
        return Load($response->content);
    }
    return 0;
}

1;
