#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 8;
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
        'ru::' => [ # data equal to ru/LC_MESSAGES/test.po
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
                    . "Plural-Forms: nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;\n",
            },
            {
                # utf-8 at msgstr only
                msgid  => "book",
                msgstr => "книга",
            },
            {
                # utf-8 at all
                msgid  => "§ book",
                msgstr => "§ книга",
            },
            {
                # plural
                msgid         => "{count} book",
                msgid_plural  => "{count} books",
                msgstr_plural => [
                    "{count} книга",
                    "{count} книги",
                    "{count} книг",
                ],
            },
        ],
    });

my $loc = Locale::TextDomain::OO->new(
    language => 'ru',
    plugins  => [ qw( Expand::Gettext ) ],
    logger   => sub { note shift },
);
is
    $loc->__(
        'book',
    ),
    'книга',
    '__';
is
    $loc->__(
        '§ book',
    ),
    '§ книга',
    '__ utf-8';
is
    $loc->__nx(
        '{count} book',
        '{count} books',
        1,
        count => 1,
    ),
    '1 книга',
    '__nx 1';
is
    $loc->__nx(
        '{count} book',
        '{count} books',
        3,
        count => 3,
    ),
    '3 книги',
    '__nx 1';
is
    $loc->__nx(
        '{count} book',
        '{count} books',
        5,
        count => 5,
    ),
    '5 книг',
    '__nx 5';
