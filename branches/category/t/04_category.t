#!perl -T

use strict;
use warnings;

use Test::More tests => 14 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANGUAGE} = 'de_DE';
my $category         = 'LC_CATEGORY';
my $text_domain      = 'test_04';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            category    => $category,
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
        );
    },
    'create default object',
);

eq_or_diff(
    $loc->__(
        'c: This is a text.',
    ),
    'c: Das ist ein Text.',
    '__',
);

eq_or_diff(
    $loc->__x(
        'c: {name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    'c: Steffen programmiert Perl.',
    '__x',
);

eq_or_diff(
    $loc->__n(
        'c: Singular',
        'c: Plural',
        1,
    ),
    'c: Einzahl',
    '__n',
);
eq_or_diff(
    $loc->__n(
        'c: Singular',
        'c: Plural',
        2,
    ),
    'c: Mehrzahl',
    '__n',
);

eq_or_diff(
    $loc->__nx(
        'c: {num} shelf',
        'c: {num} shelves',
        1,
        num => 1,
    ),
    'c: 1 Regal',
    '__nx',
);
eq_or_diff(
    $loc->__nx(
        'c: {num} shelf',
        'c: {num} shelves',
        2,
        num => 2,
    ),
    'c: 2 Regale',
    '__nx',
);

eq_or_diff(
    $loc->__p(
        'maskulin',
        'c: Dear',
    ),
    'c: Sehr geehrter Herr',
    '__p',
);

eq_or_diff(
    $loc->__px(
        'maskulin',
        'c: Dear {name}',
        name => 'Winkler',
    ),
    'c: Sehr geehrter Herr Winkler',
    '__px',
);

eq_or_diff(
    $loc->__np(
        'better',
        'c: shelf',
        'c: shelves',
        1,
    ),
    'c: gutes Regal',
    '__np',
);
eq_or_diff(
    $loc->__np(
        'better',
        'c: shelf',
        'c: shelves',
        2,
    ),
    'c: gute Regale',
    '__np',
);

eq_or_diff(
    $loc->__npx(
        'better',
        'c: {num} shelf',
        'c: {num} shelves',
        1,
        num => 1,
    ),
    'c: 1 gutes Regal',
    '__npx',
);
eq_or_diff(
    $loc->__npx(
        'better',
        'c: {num} shelf',
        'c: {num} shelves',
        2,
        num => 2,
    ),
    'c: 2 gute Regale',
    '__npx',
);