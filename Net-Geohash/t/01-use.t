#!perl -T

use Test::More tests => 7;
use Test::Warn;

BEGIN {
	use_ok( 'Net::Geohash' );
}

warning_is {
    Net::Geohash::get()
} 'Missing lattitude/longitude param';

warning_is {
    Net::Geohash::get('nick is awesome.')
} 'geohash.org response indicates that the geocode was invalid.';

warning_is {
    Net::Geohash::get(qw/nick is awesome/)
} 'geohash.org response indicates that the geocode was invalid.';

is(Net::Geohash::get('37.371066 -121.994999'), 'http://geohash.org/9q9hxgjynrxs', 'Sunnyvale, CA');
is(Net::Geohash::get('37.77916 -122.420049'), 'http://geohash.org/9q8yym2rw1g7', 'San Francisco, CA');
is(Net::Geohash::get('40.71455 -74.007124'), 'http://geohash.org/dr5regvemn0x', 'New York, NY');

