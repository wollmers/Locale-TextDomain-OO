#!perl -T

use strict;
use warnings;

use Test::More tests => 29 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Test::Deep;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    use_ok('Locale::TextDomain::OO::TiedInterface');
}

throws_ok(
    sub {
        Locale::TextDomain::OO::TiedInterface->import(undef);
    },
    qr{\A \QAn undefined value is not a variable name}xms,
    'tie object method with an undefined method name',
);
throws_ok(
    sub {
        Locale::TextDomain::OO::TiedInterface->import(qw(__));
    },
    qr{\A \Q"__" is not a hash or a hash reference}xms,
    'tie object method __y',
);
throws_ok(
    sub {
        Locale::TextDomain::OO::TiedInterface->import(qw($__y));
    },
    qr{\A \QMethod "__y" is not a translation method}xms,
    'tie object method __y',
);

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'test';

# create the object
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
        );
    },
    'create default object',
);

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

eq_or_diff(
    $N__{'text'},
    'text',
    '%N__ scalar',
);
eq_or_diff(
    $N__{['text']},
    'text',
    '%N__ arrayref',
);
eq_or_diff(
    $N__->{'text'},
    'text',
    '$N__',
);

is_deeply(
    $N__n{['singular', 'plural', 1]},
    [qw(singular plural 1)],
    '%N__n',
);
is_deeply(
    $N__n{['singular', 'plural', 2]},
    [qw(singular plural 2)],
    '$N__',
);

