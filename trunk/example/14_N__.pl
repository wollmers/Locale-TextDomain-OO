#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::TextDomain::OO;

my $loc = Locale::TextDomain::OO->new();

# run all translations
() = print map {"$_\n"}
    $loc->N__(
        'This is a text.',
    ),
    q{},
    $loc->N__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    q{},
    $loc->N__n(
        'Singular',
        'Plural',
        1,
    ),
    q{},
    $loc->N__nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    q{},
    $loc->N__p(
        'maskulin',
        'Dear',
    ),
    q{},
    $loc->N__px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ),
    q{},
    $loc->N__np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    q{},
    $loc->N__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    );

# $Id$

__END__

Output:

This is a text.

{name} is programming {language}.
name
Steffen
language
Perl

Singular
Plural
1

{num} shelf
{num} shelves
1
num
1

maskulin
Dear

maskulin
Dear {name}
name
Winkler

better
shelf
shelves
1

better
{num} shelf
{num} shelves
1
num
1
