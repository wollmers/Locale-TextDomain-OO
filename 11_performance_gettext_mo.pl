#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR $EVAL_ERROR);
require Locale::TextDomain::OO;

local $ENV{LANGUAGE} = 'de_DE';
my $text_domain      = 'example_01';

my $loc = Locale::TextDomain::OO->new(
    text_domain     => $text_domain,
    search_dirs     => [qw(./LocaleData/)],
);

binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

# run all translations
() = 
    $loc->__(
        'This is a text.',
    ),
    $loc->__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
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
        'Dear {name}',
        name => 'Winkler',
    ),
    $loc->__np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    $loc->__np(
        'better',
        'shelf',
        'shelves',
        2,
    ),
    $loc->__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    $loc->__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ) for (0 .. 1000);

# $Id: 01_gettext_mo.pl 15 2009-08-30 11:13:33Z steffenw $

__END__

Output:

Das ist ein Text.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
gute Regale
1 gutes Regal
2 gute Regale