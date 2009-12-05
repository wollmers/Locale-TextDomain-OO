#!perl -T

use strict;
use warnings;

use Test::More tests => 16 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
require DBD::PO::Locale::PO;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::MessagesStruct');
}

local $ENV{LANGUAGE} = 'de_DE';
my $text_domain      = 'test';

my ($loc, %struct);
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            gettext_object => Locale::TextDomain::OO::MessagesStruct->new(\%struct),
            text_domain    => $text_domain,
            search_dirs    => [qw(./t/LocaleData/)],
        );
    },
    'create extended object',
);

# find the database for the expected language
# here fallback to 'de'
my $file_path = $loc->get_file_path($text_domain, '.po');

my $locale_po = DBD::PO::Locale::PO->new();
my $array_ref = $locale_po->load_file_asarray("$file_path/$text_domain.po");

# header
my $header = ( shift @{$array_ref} )->msgstr();
my ($plural_forms) = $header=~  m{^ Plural-Forms: \s (.*) \n}xms;

# convert array_ref of objects to array_ref of hashes
for my $entry ( @{$array_ref} ) {
    $entry = {
        msgctxt      => scalar $entry->msgctxt(),
        msgid        => scalar $entry->msgid(),
        msgid_plural => scalar $entry->msgid_plural(),
        msgstr       => scalar $entry->msgstr(),
        do {
            my $msgstr_n = $entry->msgstr_n();
            $msgstr_n
            ? (
                map {
                    ( "msgstr_$_" => $msgstr_n->{$_} );
                } keys %{$msgstr_n}
            )
            : ();
        },
    };
}

# build the struct and bind the struct as object to the text domain
%struct = (
    $text_domain => {
        plural_ref => $loc->get_function_ref_plural($plural_forms),
        array_ref  => $array_ref,
    },
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
