#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 17;
use Test::NoWarnings;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::Lexicon::Hash');
}

Locale::TextDomain::OO::Lexicon::Hash
    ->new(
        logger => sub { note shift },
    )
    ->lexicon_ref({
        'de:LC_MESSAGES:test' => [ # data equal to de/LC_MESSAGES/test.po
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
            {
                # __
                msgid  => "This is a text.",
                msgstr => "Das ist ein Text.",
            },
            {
                # __ umlaut
                msgid  => "§ book",
                msgstr => "§ Buch",
            },
            {
                # __x
                msgid  => "{name} is programming {language}.",
                msgstr => "{name} programmiert {language}.",
            },
            {
                # __n
                msgid         => "Singular",
                msgid_plural  => "Plural",
                msgstr_plural => [
                    "Einzahl",
                    "Mehrzahl",
                ],
            },
            {
                # __nx
                msgid         => "{num} shelf",
                msgid_plural  => "{num} shelves",
                msgstr_plural => [
                    "{num} Regal",
                    "{num} Regale",
                ],
            },
            {
                # __p
                msgctxt => "maskulin",
                msgid   => "Dear",
                msgstr  => "Sehr geehrter",
            },
            {
                # __px
                msgctxt => "maskulin",
                msgid   => "Dear {full name}",
                msgstr  => "Sehr geehrter {full name}",
            },
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
    language => 'de',
    category => 'LC_MESSAGES',
    domain   => 'test',
    plugins  => [ qw( Expand::Gettext ) ],
    logger   => sub { note shift },
);
is
    $loc->__(
        'This is a text.',
    ),
    'Das ist ein Text.',
    '__';
is
    $loc->__(
        '§ book',
    ),
    '§ Buch',
    '__ umlaut';
is
    $loc->__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    'Steffen programmiert Perl.',
    '__x';
is
    $loc->__x(
        '{name} is programming {language}.',
        name => 'Steffen',
    ),
    'Steffen programmiert {language}.',
    '__x (missing palaceholder)';
is
    $loc->__n(
        'Singular',
        'Plural',
        1,
    ),
    'Einzahl',
    '__n 1';
is
    $loc->__n(
        'Singular',
        'Plural',
        2,
    ),
    'Mehrzahl',
    '__n 2';
is
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 Regal',
    '__nx 1';
is
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    '2 Regale',
    '__nx 2';
is
    $loc->__p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter',
    '__p';
is
    $loc->__px(
        'maskulin',
        'Dear {full name}',
        'full name' => 'Steffen Winkler',
    ),
    'Sehr geehrter Steffen Winkler',
    '__px';
is
    $loc->__np(
        'appointment',
        'date',
        'dates',
        1,
    ),
    'Date',
    '__np 1';
is
    $loc->__np(
        'appointment',
        'date',
        'dates',
        2,
    ),
    'Dates',
    '__np 2';
is
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        1,
        num => 1,
    ),
    'Das ist 1 Date.',
    '__npx 1';
is
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        2,
        num => 2,
    ),
    'Das sind 2 Dates.',
    '__npx 2';
