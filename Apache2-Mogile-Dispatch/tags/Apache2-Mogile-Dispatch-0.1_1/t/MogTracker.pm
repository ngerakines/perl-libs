package MogTracker;

use strict;
use warnings;

use Data::Dumper;

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
use Apache2::Const -compile => qw(DECLINED OK OR_ALL RSRC_CONF TAKE1 RAW_ARGS NO_ARGS DONE );

use constant METHOD => 'get_paths';

sub handler {
    my $r = shift;
    $r->server->method_register(METHOD);
    $r->handler("perl-script");
    $r->push_handlers(PerlResponseHandler => \&handle_response);
    return Apache2::Const::OK;
}

sub handle_response {
      my $r = shift;
      my $uri = $r->uri;
      if ($r->uri eq 'domain=socklabs&noverify=1&key=/apache-perl.typepad.com/') {
          $r->print(<<'EOF');
OK path1=http://localhost:8532/f0/000/0000/00000.fid&path2=http://localhost:8533/f0/000/0000/00000.fid&paths=1
EOF
      }
      if ($r->uri eq'domain=socklabs&noverify=1&key=/apache-perl.typepad.com/home/') {
          $r->print(<<'EOF');
OK path1=http://localhost:8532/f0/000/0000/00001.fid&paths=1
EOF
    }
      return Apache2::Const::OK;
}

1;

