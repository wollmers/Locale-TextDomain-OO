#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 20;
use Test::NoWarnings;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::Lexicon::File::MO');
}

Locale::TextDomain::OO::Lexicon::File::MO
    ->new(
        logger => sub {
            my ($message, $arg_ref ) = @_;
            $message =~ s{\\}{/}xmsg;
            like
                $message,
                qr{
                    \A
                    \QLexicon "\E
                    ( de | ru )
                    \Q::" loaded from file "t/LocaleData/\E
                    \1
                    \Q/LC_MESSAGES/test.mo".\E
                    \z
                }xms,
                'message';
            is
                ref $arg_ref->{object},
                'Locale::TextDomain::OO::Lexicon::File::MO',
                'logger object';
            is
                $arg_ref->{type},
                'debug',
                'logger type';
            is
                $arg_ref->{event},
                'lexicon,load',
                'logger event';
            return;
        },
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
    plugins  => [ qw( Expand::Gettext ) ],
    logger   => sub {
        my ($message, $arg_ref ) = @_;
        is
            $message,
            '',
            'message';
        is
            ref $arg_ref->{object},
            'Locale::TextDomain::OO::Lexicon::Hash',
            'logger object';
        is
            $arg_ref->{type},
            'debug',
            'logger type';
        is
            $arg_ref->{event},
            'lexicon,load',
            'logger event';
        return;
    },
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
is
    $loc->__p(
        'appointment',
        'date',
    ),
    'воссоединение',
    '__p';
is
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        1,
        num => 1,
    ),
    'Это 1 воссоединение.',
    '__npx 1';
is
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        3,
        num => 3,
    ),
    'Это 3 воссоединения.',
    '__npx 3';
is
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        5,
        num => 5,
    ),
    'Эти 5 воссоединения.',
    '__npx 5';
