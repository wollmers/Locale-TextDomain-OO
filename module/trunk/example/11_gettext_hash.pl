#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Locale::TextDomain::OO::Lexicon::Hash;
use Locale::TextDomain::OO;

# Lexicon from hash
Locale::TextDomain::OO::Lexicon::Hash->new->lexicon_ref({
    # data equal to de/LC_MESSAGES/test.po (.mo)
    # language -----^^ ^^^^^^^^^^^ ^^^^
    # category -------´           /
    # domain --------------------´
    'de:LC_MESSAGES:test' => [
        # header similar to po file
        {
            msgid  => "",
            msgstr => ""
                . "Project-Id-Version: \n"
                . "POT-Creation-Date: \n"
                . "PO-Revision-Date: \n"
                . "Last-Translator: \n"
                . "Language-Team: \n"
                . "MIME-Version: 1.0\n"
                . "Content-Type: text/plain; charset=UTF-8\n"
                . "Content-Transfer-Encoding: 8bit\n"
                . "Plural-Forms: nplurals=2; plural=n != 1;\n",
        },
        # en -> de translation
        {
            # __
            msgid  => "This is a text.",
            msgstr => "Das ist ein Text.",
        },
        # with named placeholder
        {
            # __x
            msgid  => "{name} is programming {language}.",
            msgstr => "{name} programmiert {language}.",
        },
        # 2 en plural forms -> 2 de plural forms
        {
            # __n
            msgid         => "Singular",
            msgid_plural  => "Plural",
            msgstr_plural => [
                # in po file written as msgstr[0]
                "Einzahl",
                # in po file written as msgstr[1]
                "Mehrzahl",
            ],
        },
        # plural translation + named placeholder
        {
            # __nx
            msgid         => "{num} shelf",
            msgid_plural  => "{num} shelves",
            msgstr_plural => [
                "{num} Regal",
                "{num} Regale",
            ],
        },
        # context - different meaning but the same English phrase for both
        {
            # __p
            msgctxt => "maskulin",
            msgid   => "Dear",
            msgstr  => "Sehr geehrter",
        },
        # context + named placeholder
        {
            # __px
            msgctxt => "maskulin",
            msgid   => "Dear {full name}",
            msgstr  => "Sehr geehrter {full name}",
        },
        # context + plural
        {
            # __np
            msgctxt       => "appointment",
            msgid         => "date",
            msgid_plural  => "dates",
            msgstr_plural => [
                "Date",
                "Dates",
            ],
        },
        # context + plural + named placeholder
        {
            # __npx
            msgctxt       => "appointment",
            msgid         => "This is {num} date.",
            msgid_plural  => "This are {num} dates.",
            msgstr_plural => [
                "Das ist {num} Date.",
                "Das sind {num} Dates.",
            ],
        },
    ],
});

my $loc = Locale::TextDomain::OO->new(
    language => 'de',          # default is 'i-default'
    category => 'LC_MESSAGES', # default is q{}
    domain   => 'test',        # default is q{}
    plugins  => [ qw( Expand::Gettext ) ],
);

# run all translations
() = print map {"$_\n"}
    $loc->__(
        'This is a text.',
    ),
    $loc->__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    $loc->__x(
        '{name} is programming {language}.',
        name => 'Steffen',
    ),
    $loc->__n(
        'Singular',
        'Plural',
        1,
    ),
    $loc->__n(
        'Singular',
        'Plural',
        2,
    ),
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    $loc->__p(
        'maskulin',
        'Dear',
    ),
    $loc->__px(
        'maskulin',
        'Dear {full name}',
        'full name' => 'Steffen Winkler',
    ),
    $loc->__np(
        'appointment',
        'date',
        'dates',
        1,
    ),
    $loc->__np(
        'appointment',
        'date',
        'dates',
        2,
    ),
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        1,
        num => 1,
    ),
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        2,
        num => 2,
    );

# $Id$

__END__

Output:

Das ist ein Text.
Steffen programmiert Perl.
Steffen programmiert {language}.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter
Sehr geehrter Steffen Winkler
Date
Dates
Das ist 1 Date.
Das sind 2 Dates.
