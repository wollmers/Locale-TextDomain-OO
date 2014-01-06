#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 9;
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
        search_dirs => [ './t/LocaleData' ],
        decode      => 1,
        data        => [
            '*::' => '*/LC_MESSAGES/test.mo',
        ],
    });

my $loc = Locale::TextDomain::OO->new(
    language => 'ru',
    plugins  => [ qw( Expand::Maketext::Localize ) ],
    logger   => sub { note shift },
);
is
    $loc->localize(
        'book',
    ),
    'книга',
    'localize';
is
    $loc->localize(
        '§ book',
    ),
    '§ книга',
    'localize, umlaut';
is
    $loc->localize_p(
        'appointment',
        'date',
    ),
    'воссоединение',
    'localize_p';
is
    $loc->Nlocalize(
        'book',
    ),
    'book',
    'Nlocalize';
eq_or_diff
    [
        $loc->Nlocalize_p(
            'appointment',
            'date',
        ),
    ],
    [
        'appointment',
        'date',
    ],
    'Nlocalize_p';
eq_or_diff
    [
        $loc->Nlocalize_p(
            'not existing context',
            'book',
        ),
    ],
    [
        'not existing context',
        'book',
    ],
    'Nlocalize_p (not in lexicon)';
