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
    @realms = map { $_->{'n'} } @realms;
}

my $realmcount = $#realms;

print "Realms processed ($realmcount): " . join(', ', @realms ) . "\n";

for (1 .. 5) {
   my $rr = int rand($realmcount);
   print "Realm $rr ($realms[$rr])\n";
   my $realm = $rs->realm($realms[$rr]);
   print Data::Dumper::Dumper( $realm ) . "\n";
}

for (1 .. 5) {
   my $rr = int rand($realmcount);
   print "Realm $rr ($realms[$rr])\n";
   my $realm = $rs->realm_json($realms[$rr]);
   print Data::Dumper::Dumper( $realm ) . "\n";
}
