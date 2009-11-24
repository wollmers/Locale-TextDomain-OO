#!perl -T

use strict;
use warnings;

use Test::More tests => 12 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    use_ok('Locale::TextDomain::OO::FunctionalInterface');
}

{
    my $loc;

    lives_ok(
        sub {
            $loc = Locale::TextDomain::OO->new(
                language    => 'de_DE',
                text_domain => 'test',
                search_dirs => [qw(./t/LocaleData)],
            );
        },
        'create default object',
    );

    lives_ok(
        sub {
            bind_object($loc);
        },
        'bind object',
    );
}

# run all translations
eq_or_diff(
    __(
        'This is a text.',
    ),
    'Das ist ein Text.',
    '__',
);

eq_or_diff(
    __x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    'Steffen programmiert Perl.',
    '__x',
);

eq_or_diff(
    __n(
        'Singular',
        'Plural',
        1,
    ),
    'Einzahl',
    '__n',
);

eq_or_diff(
    __nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 Regal',
    '__nx',
);

eq_or_diff(
    __p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter Herr',
    '__p',
);

eq_or_diff(
    __px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ),
    'Sehr geehrter Herr Winkler',
    '__px',
);

eq_or_diff(
    __np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    'gutes Regal',
    '__np',
);

eq_or_diff(
    __npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 gutes Regal',
    '__npx',
);
