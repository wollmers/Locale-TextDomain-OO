#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::TextDomain::OO;

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'example';

my $loc = Locale::TextDomain::OO->new(
    text_domain => $text_domain,
    search_dirs => [qw(./LocaleData/)],
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
    );

# $Id: 11_gettext_mo.pl 271 2010-01-16 07:37:06Z steffenw $

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