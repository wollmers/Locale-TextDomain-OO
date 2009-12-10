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

# create the object
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

# tie the method calls
my (
    %__,    $__,
    %__x,   $__x,
    %__n,   $__n,
    %__nx,  $__nx,
    %__p,   $__p,
    %__px,  $__px,
    %__np,  $__np,
    %__npx, $__npx,
);
lives_ok(
    sub {
        tie_object(
            $loc,
            __    => \%__,
            __    => $__,
            __x   => \%__x,
            __x   => $__x,
            __n   => \%__n,
            __n   => $__n,
            __nx  => \%__nx,
            __nx  => $__nx,
            __p   => \%__p,
            __p   => $__p,
            __px  => \%__px,
            __px  => $__px,
            __np  => \%__np,
            __npx => \%__npx,
            __npx => $__npx,
        );
    },
    'tie all object methods',
);
throws_ok(
    sub {
        tie_object($loc, undef() => undef);
    },
    qr{\A \QAn undefined value is not a method name}xms,
    'tie object method with an undefined method name',
);
throws_ok(
    sub {
        tie_object($loc, __y => undef);
    },
    qr{\A \QMethod "__y" is not a translation method}xms,
    'tie object method __y',
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

