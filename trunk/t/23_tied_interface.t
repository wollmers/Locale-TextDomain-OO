#!perl -T

use strict;
use warnings;

use Test::More tests => 15 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    use_ok('Locale::TextDomain::OO::TiedInterface');
}

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'test';

{
    my $loc;

    lives_ok(
        sub {
            $loc = Locale::TextDomain::OO->new(
                text_domain => $text_domain,
                search_dirs => [qw(./t/LocaleData)],
            );
        },
        'create default object',
    );

    lives_ok(
        sub {
            tie_object($loc);
        },
        'tie object',
    );

    lives_ok(
        sub {
            tie_object($loc, qw(%__ $__));
        },
        'tie object method __ to %__ and $__',
    );

    throws_ok(
        sub {
            tie_object($loc, undef);
        },
        qr{\A \QAn undefined value is not a variable name}xms,
        'tie object method with an undefined method name',
    );

    throws_ok(
        sub {
            tie_object($loc, qw(%__x %__y));
        },
        qr{\A \QMethod "__y" is not a translation method}xms,
        'tie object method __x, __y to %__x, %__y',
    );
}

# run all translations
eq_or_diff(
    $__{
        'This is a text.',
    },
    'Das ist ein Text.',
    '%__',
);
eq_or_diff(
    $__->{
        'This is a text.',
    },
    'Das ist ein Text.',
    '$__',
);
eq_or_diff(
    $__{[
        'This is a text.',
    ]},
    'Das ist ein Text.',
    '%__',
);
eq_or_diff(
    $__->{[
        'This is a text.',
    ]},
    'Das ist ein Text.',
    '$__',
);

eq_or_diff(
    $__{[
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ]},
    'Steffen programmiert Perl.',
    '%__x',
);
eq_or_diff(
    $__x->{[
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ]},
    'Steffen programmiert Perl.',
    '$__x',
);

eq_or_diff(
    $__n{[
        'Singular',
        'Plural',
        1,
    ]},
    'Einzahl',
    '%__n',
);
eq_or_diff(
    $__n->{[
        'Singular',
        'Plural',
        1,
    ]},
    'Einzahl',
    '$__n',
);

eq_or_diff(
    $__nx{[
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ]},
    '1 Regal',
    '%__nx',
);
eq_or_diff(
    $__nx->{[
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ]},
    '1 Regal',
    '$__nx',
);

eq_or_diff(
    $__p{[
        'maskulin',
        'Dear',
    ]},
    'Sehr geehrter Herr',
    '%__p',
);
eq_or_diff(
    $__p->{[
        'maskulin',
        'Dear',
    ]},
    'Sehr geehrter Herr',
    '$__p',
);

eq_or_diff(
    $__px{[
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ]},
    'Sehr geehrter Herr Winkler',
    '%__px',
);
eq_or_diff(
    $__px->{[
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ]},
    'Sehr geehrter Herr Winkler',
    '$__px',
);

eq_or_diff(
    $__np{[
        'better',
        'shelf',
        'shelves',
        1,
    ]},
    'gutes Regal',
    '%__np',
);
eq_or_diff(
    $__np->{[
        'better',
        'shelf',
        'shelves',
        1,
    ]},
    'gutes Regal',
    '$__np',
);

eq_or_diff(
    $__npx{[
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ]},
    '1 gutes Regal',
    '%__npx',
);
eq_or_diff(
    $__npx->{[
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ]},
    '1 gutes Regal',
    '$__npx',
);

