#!perl -T

use strict;
use warnings;

use Test::More tests => 4;
use Test::NoWarnings;
use Test::Differences;

BEGIN {
    use_ok('Locale::Utils::PlaceholderNamed');
}

my $obj = Locale::Utils::PlaceholderNamed->new(
    modifier_code => sub {
        my ($value, $attribute) = @_;
        if ( $attribute eq 'int' ) {
            return int $value;
        }
        return $value;
    },
);

eq_or_diff
    $obj->expand_named('{a} {b} {c:int} {d :int}'),
    '{a} {b} {c:int} {d :int}',
    'expand empty';
eq_or_diff
    $obj->expand_named(
        '{a} {b} {c:int} {d :int}',
        a => 'a',
        b => 2,
        c => '3234567.890',
        d => 4234567.890,
    ),
    'a 2 3234567 4234567',
    'expand hash';
