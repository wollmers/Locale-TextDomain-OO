#!perl -T

use strict;
use warnings;

use Test::More tests => 3;
use Test::NoWarnings;
use Test::Exception;

BEGIN {
    use_ok('Locale::Utils::PlaceholderMaketext');
}

throws_ok
    sub {
        Locale::Utils::PlaceholderMaketext->new(xxx => 1);
    },
    qr{unknown \s+ attribute .+? xxx}xms,
    'false attribute';
