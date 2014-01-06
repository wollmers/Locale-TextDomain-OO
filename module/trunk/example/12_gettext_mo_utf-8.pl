#!perl -T ## no critic (TidyCode)

use strict;
use warnings;
use utf8;
use Carp qw(confess);
use English qw(-no_match_vars $OS_ERROR);
use Locale::TextDomain::OO;
use Locale::TextDomain::OO::Lexicon::File::MO;

our $VERSION = 0;

Locale::TextDomain::OO::Lexicon::File::MO
    ->new(
        logger => sub {
            my ($message, $arg_ref) = @_;
            () = print "$arg_ref->{type}: $message\n";
            return;
        },
    )
    ->lexicon_ref({
        search_dirs => [ './LocaleData' ],
        decode      => 1, # from UTF-8, see header of po/mo file
        data        => [
            # map category and domain to q{}
            '*::' => '*/LC_MESSAGES/example.mo',
        ],
    });

my $loc = Locale::TextDomain::OO->new(
    language => 'ru',
    logger   => sub { () = print shift, "\n" },
    plugins  => [ qw( Expand::Gettext ) ],
);

# all unicode chars encode to UTF-8
binmode STDOUT, ':encoding(utf-8)'
    or confess "Binmode STDOUT\n$OS_ERROR";

# run translations
() = print map {"$_\n"}
    $loc->__(
        'not existing text',
    ),
    $loc->__(
        'book',
    ),
    $loc->__nx(
        '{count} book',
        '{count} books',
        1,
        count => 1,
    ),
    $loc->__nx(
        '{count} book',
        '{count} books',
        3, ## no critic (MagicNumbers)
        count => 3,
    ),
    $loc->__nx(
        '{count} book',
        '{count} books',
        5, ## no critic (MagicNumbers)
        count => 5,
    ),
    $loc->__p(
        'appointment',
        'date',
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
        3, ## no critic (MagicNumbers)
        num => 3,
    ),
    $loc->__npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        5, ## no critic (MagicNumbers)
        num => 5,
    );

# $Id$

__END__

Output:

info: Lexicon "de::" loaded from file "LocaleData/de/LC_MESSAGES/example.mo".
info: Lexicon "ru::" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo".
Using lexicon "ru::". msgstr not found for msgctxt=undef, msgid="not existing text".
not existing text
книга
1 книга
3 книги
5 книг
воссоединение
Это 1 воссоединение.
Это 3 воссоединения.
Эти 5 воссоединения.
