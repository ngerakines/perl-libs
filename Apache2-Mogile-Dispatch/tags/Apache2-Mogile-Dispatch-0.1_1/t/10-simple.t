
use Apache::Test qw(:withtestmore);
use Apache::TestRequest qw(GET POST);
use Apache2::Const -compile => qw(:common); 

use Test::More no_plan => 1;
use Test::Group;

use Data::Dumper;

Apache::TestRequest::module('setone');

test 'ngerakines.typepad.com - status ok' => sub {
    my $res = GET '/', 'Host' => 'ngerakines.typepad.com';
    is($res->header('x-reproxy-url'), 'http://blog.socklabs.com/', 'direct reproxy rule -- good');
    is($res->message, 'OK', 'Request is ok');
    is($res->code, '200', 'Request is ok');
};

test 'localhost - status ok' => sub {
    my $res = GET '/', 'Host' => 'localhost';
    is($res->message, 'OK', 'Request is ok');
    is($res->code, '200', 'Request is ok');
};

test 'apache.perl.org simple - status ok' => sub {
    my $res = GET '/home/', 'Host' => 'apache.perl.org';
    is($res->message, 'OK', 'Request is ok');
    is($res->code, '200', 'Request is ok');
    like($res->content, qr/Home/, 'content match');
};

test 'apache.perl.org with include - status ok' => sub {
    my $res = GET '/', 'Host' => 'apache.perl.org';
    is($res->message, 'OK', 'Request is ok');
    is($res->code, '200', 'Request is ok');
    like($res->content, qr/Index/, 'content match');
    like($res->content, qr/Home/, 'content match');
};

test 'apache.perl.org not found - 404k' => sub {
    my $res = GET '/bio/', 'Host' => 'apache.perl.org';
    is($res->message, 'Not Found', 'file not found -- good');
    is($res->code, '404', '404 returned -- good');
};


