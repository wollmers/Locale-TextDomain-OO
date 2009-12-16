#!perl -T

use strict;
use warnings;

use Test::More tests => 15 + 1;
use Test::NoWarnings;
use Test::Exception;

BEGIN {
    require_ok('Locale::TextDomain::OO::Extract');
}

my $extractor;
lives_ok(
    sub {
        $extractor = Locale::TextDomain::OO::Extract->new();
    },
    'create extractor object',
);

$extractor->extract('./t/11_basics.t');