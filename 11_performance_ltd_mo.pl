#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::TextDomain;

local $ENV{LANGUAGE} = 'de_DE';
my $text_domain      = 'example';

Locale::TextDomain->import( $text_domain => qw(./LocaleData/) );

# run all translations
() =
    __(
        'This is a text.',
    ),
    __x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    __n(
        'Singular',
        'Plural',
        1,
    ),
    __n(
        'Singular',
        'Plural',
        2,
    ),
    __nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    __nx(
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    __p(
        'maskulin',
        'Dear',
    ),
    __px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ),
    __np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    __np(
        'better',
        'shelf',
        'shelves',
        2,
    ),
    __npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    __npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ) for (1 .. 1_000);

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
