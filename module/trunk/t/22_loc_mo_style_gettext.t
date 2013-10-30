#!perl -T

use strict;
use warnings;

use Test::More tests => 18;
use Test::NoWarnings;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::Lexicon::File::MO');
}

Locale::TextDomain::OO::Lexicon::File::MO
    ->new(
        logger => sub { note shift },
    )
    ->lexicon_ref({
        search_dirs         => [ './t/LocaleData' ],
        gettext_to_maketext => 1,
        data                => [
            '*:LC_MESSAGES:test_maketext_style_gettext' => '*/LC_MESSAGES/test_maketext_style_gettext.mo',
        ],
    });

my $loc = Locale::TextDomain::OO->new(
    language => 'de',
    category => 'LC_MESSAGES',
    domain   => 'test_maketext_style_gettext',
    plugins  => [ qw( Expand::Maketext::Loc ) ],
    logger   => sub { note shift },
);
is
    $loc->loc(
        'This is a text.',
    ),
    'Das ist ein Text.',
    'loc';
is
    $loc->loc(
        '� book',
    ),
    '� Buch',
    'loc, umlaut';
is
    $loc->loc(
        '[_1] is programming [_2].',
        'Steffen',
        'Perl',
    ),
    'Steffen programmiert Perl.',
    'loc, placeholder';
is
    $loc->loc(
        '[_1] is programming [_2].',
        'Steffen',
    ),
    'Steffen programmiert .',
    'loc, missing placeholder';
is
    $loc->loc(
        '[quant,_1,shelf,shelves]',
        1,
    ),
    '1 Regal',
    'loc, quant 1';
is
    $loc->loc(
        '[quant,_1,shelf,shelves]',
        2,
    ),
    '2 Regale',
    'loc, quant 2';
is
    $loc->loc_p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter',
    'loc_p';
is
    $loc->loc_p(
        'maskulin',
        'Dear [_1]',
        'Steffen Winkler',
    ),
    'Sehr geehrter Steffen Winkler',
    'loc_p, placeholder';
is
    $loc->loc_p(
        'appointment',
        '[*,_1,date,dates]',
        1,
    ),
    '1 Date',
    'loc_p, * 1';
is
    $loc->loc_p(
        'appointment',
        '[*,_1,date,dates]',
        2,
    ),
    '2 Dates',
    'loc_p, * 2';
is
    $loc->loc(
        '[*,_1,shelf,shelves,no shelf]',
        0,
    ),
    'kein Regal',
    'loc, * 0';
is
    $loc->loc(
        '[*,_1,shelf,shelves,no shelf]',
        1,
    ),
    '1 Regal',
    'loc, * 1';
is
    $loc->loc(
        '[*,_1,shelf,shelves,no shelf]',
        2,
    ),
    '2 Regale',
    'loc, * 2';
is
    $loc->Nloc(
        'book',
    ),
    'book',
    'Nloc';
eq_or_diff
    [
        $loc->Nloc_p(
            'not existing context',
            'book',
        ),
    ],
    [
        'not existing context',
        'book',
    ],
    'Nloc_p';
