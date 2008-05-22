#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use WWW::Wow::RealmStatus;

my $rs = WWW::Wow::RealmStatus->new(
    'memcached_servers' => ['localhost:11211']
);

my @realms = $rs->get_realms();
if (! @realms) {
    @realms = $rs->process();
    $rs->save_realms(map { $_->{'n'} } @realms);
}

