#!perl -T

use strict;
use warnings;

use Test::More tests => 16 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANG} = ();
local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'test';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
        );
    },
    'create object',
);

# run all translations
eq_or_diff(
    $loc->__(
        'This is a text.',
    ),
    'Das ist ein Text.',
    '__',
);
eq_or_diff(
    $loc->__(
        '§ book',
    ),
    '§ Buch',
    '__ umlaut',
);

eq_or_diff(
    $loc->__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    'Steffen programmiert Perl.',
    '__x',
);
eq_or_diff(
    $loc->__x(
        '{name} is programming {language}.',
        name => 'Steffen',
    ),
    'Steffen programmiert {language}.',
    '__x (missing palaceholder)',
);

eq_or_diff(
    $loc->__n(
        'Singular',
        'Plural',
        1,
    ),
    'Einzahl',
    '__n 1',
);
eq_or_diff(
    $loc->__n(
        'Singular',
        'Plural',
        2,
    ),
    'Mehrzahl',
    '__n 2',
);

eq_or_diff(
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 Regal',
    '__nx 1',
);
eq_or_diff(
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    '2 Regale',
    '__nx 2',
);

eq_or_diff(
    $loc->__p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter Herr',
    '__p',
);

eq_or_diff(
    $loc->__px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ),
    'Sehr geehrter Herr Winkler',
    '__px',
);

eq_or_diff(
    $loc->__np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    'gutes Regal',
    '__np 1',
);
eq_or_diff(
    $loc->__np(
        'better',
        'shelf',
        'shelves',
        2,
    ),
    'gute Regale',
    '__np 2',
);

eq_or_diff(
    $loc->__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 gutes Regal',
    '__npx 1',
);
eq_or_diff(
    $loc->__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    '2 gute Regale',
    '__npx 2',
);