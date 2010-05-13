#!perl -T

use strict;
use warnings;

use Test::More tests => 15 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO::Maketext');
}

local $ENV{LANG} = ();
local $ENV{LANGUAGE}
    = Locale::TextDomain::OO::Maketext
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'test_maketext';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO::Maketext->new(
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
        );
    },
    'create maketext object',
);

# run all translations
eq_or_diff(
    $loc->maketext(
        'This is a text.',
    ),
    'Das ist ein Text.',
    'maketext like __',
);
eq_or_diff(
    $loc->maketext(
        '§ book',
    ),
    '§ Buch',
    'maketext like __ and umlaut',
);

eq_or_diff(
    $loc->maketext(
        '[_1] is programming [_2].',
        'Steffen',
        'Perl',
    ),
    'Steffen programmiert Perl.',
    'maketext like __x',
);
eq_or_diff(
    $loc->maketext(
        '[_1] is programming [_2].',
        'Steffen',
    ),
    'Steffen programmiert [_2].',
    'maketext like __x (missing placeholder)',
);

eq_or_diff(
    $loc->maketext(
        '[quant,_1,shelf,shelves]',
        1,
    ),
    '1 Regal',
    'maketext like __nx 1',
);
eq_or_diff(
    $loc->maketext(
        '[quant,_1,shelf,shelves]',
        2,
    ),
    '2 Regale',
    'maketext like __nx 2',
);

eq_or_diff(
    $loc->maketext_p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter Herr',
    'maketext like __p',
);

eq_or_diff(
    $loc->maketext_p(
        'maskulin',
        'Dear [_1]',
        'Winkler',
    ),
    'Sehr geehrter Herr Winkler',
    'maketext like __px',
);

eq_or_diff(
    $loc->maketext_p(
        'better',
        '[*,_1,shelf,shelves]',
        1,
    ),
    '1 gutes Regal',
    'maketext like __npx 1',
);
eq_or_diff(
    $loc->maketext_p(
        'better',
        '[*,_1,shelf,shelves]',
        2,
    ),
    '2 gute Regale',
    'maketext like __npx 2',
);

eq_or_diff(
    $loc->maketext(
        '[*,_1,shelf,shelves,no shelf]',
        0,
    ),
    '0 Regale',
    'maketext with zero like __npx 0',
);
eq_or_diff(
    $loc->maketext(
        '[*,_1,shelf,shelves,no shelf]',
        1,
    ),
    '1 Regal',
    'maketext with zero like __npx 1',
);
eq_or_diff(
    $loc->maketext(
        '[*,_1,shelf,shelves,no shelf]',
        2,
    ),
    '2 Regale',
    'maketext with zero like __npx2',
);