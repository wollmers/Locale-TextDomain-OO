#!perl -T

use strict;
use warnings;

use Test::More tests => 10 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new();
    },
    'create minimal object',
);

eq_or_diff(
    $loc->N__(
        'This is a text.',
    ),
    'This is a text.',
    'N__',
);

eq_or_diff(
    [ $loc->N__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ) ],
    [
        '{name} is programming {language}.',
        'name',
        'Steffen',
        'language',
        'Perl',
    ],
    'N__x',
);

eq_or_diff(
    [ $loc->N__n(
        'Singular',
        'Plural',
        1,
    ) ],
    [ qw(Singular Plural 1) ],
    'N__n',
);

eq_or_diff(
    [ $loc->N__nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ) ],
    [
        '{num} shelf',
        '{num} shelves',
        1,
        'num',
        1,
    ],
    'N__nx',
);

eq_or_diff(
    [ $loc->N__p(
        'maskulin',
        'Dear',
    ) ],
    [ qw(maskulin Dear) ],
    'N__p',
);

eq_or_diff(
    [ $loc->N__px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ) ],
    [
        'maskulin',
        'Dear {name}',
        'name',
        'Winkler',
    ],
    'N__px',
);

eq_or_diff(
    [ $loc->N__np(
        'better',
        'shelf',
        'shelves',
        1,
    ) ],
    [ qw(better shelf shelves 1) ],
    'N__np',
);

eq_or_diff(
    [ $loc->N__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ) ],
    [
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        'num',
        1,
    ],
    'N__npx',
);