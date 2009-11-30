#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::TextDomain::OO;
use Locale::TextDomain::OO::FunctionalInterface qw(bind_object);

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'example';

bind_object(
    Locale::TextDomain::OO->new(
        text_domain => $text_domain,
        search_dirs => [qw(./LocaleData/)],
    ),
);

# run all translations
() = print map {"$_\n"}
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
    );

# $Id$

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