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

# Put all data for the translation into a structure.
# That allows the extractor to find all the phrases.
my @extractable_data = (
    '' => [
        $loc->N__(
            'This is a text.',
        )
    ],
    x => [
        $loc->N__x(
            '{name} is programming {language}.',
            name     => 'Steffen',
            language => 'Perl',
        )
    ],
    n => [
        $loc->N__n(
            'Singular',
            'Plural',
            1,
        )
    ],
    nx => [
        $loc->N__nx(
            '{num} shelf',
            '{num} shelves',
            1,
            num => 1,
        )
    ],
    p => [
        $loc->N__p(
            'maskulin',
            'Dear',
        )
    ],
    px => [
        $loc->N__px(
            'maskulin',
            'Dear {name}',
            name => 'Winkler',
        )
    ],
    np => [
        $loc->N__np(
            'better',
            'shelf',
            'shelves',
            1,
        )
    ],
    npx => [
        $loc->N__npx(
            'better',
            '{num} shelf',
            '{num} shelves',
            1,
            num => 1,
        )
    ],
);

# Do any complex things and run the translations later.
while (my ($method_suffix, $array_ref) = splice @extractable_Data, 0, 2) {
    my $method = "__$mtheod_suffix;
    $loc->$method( @{$array_ref );
}

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