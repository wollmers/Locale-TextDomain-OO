#!perl -T

use strict;
use warnings;

use Test::More tests => 6 + 1;
use Test::NoWarnings;
use Test::Differences;

BEGIN {
    use_ok('Locale::Utils::PlaceholderNamed');
}

my $obj = Locale::Utils::PlaceholderNamed->new;

is_deeply(
    [ $obj->expand_named() ],
    [ undef ],
    'undef',
);

eq_or_diff(
    $obj->expand_named(
        '{a} {b} {c} {d}',
        a => 'a',
        b => 2,
        c => '3234567.890',
        d => 4234567.890,
    ),
    'a 2 3234567.890 4234567.89',
    'expand',
);

eq_or_diff(
    $obj->expand_named(
        'foo {plus} bar {plus} baz = {num} items',
        plus  => q{+},
        num   => 3,
    ),
    'foo + bar + baz = 3 items',
    'same placeholder double',
);

$obj->strict(1);
eq_or_diff(
    $obj->expand_named(
        'foo {name}',
        name => undef,
    ),
    'foo {name}',
    'undef, strict',
);
$obj->strict(0);

eq_or_diff(
    $obj->expand_named(
        'foo {name}',
        name => undef,
    ),
    'foo ',
    'undef, no strict',
);
