#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::TextDomain::OO::Maketext;

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO::Maketext
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'example_maketext';

my $loc = Locale::TextDomain::OO::Maketext->new(
    text_domain => $text_domain,
    search_dirs => [qw(./LocaleData/)],
);

# run all translations
() = print map {"$_\n"}
    $loc->maketext(
        'This is a text.',
    ),
    $loc->maketext(
        '[_1] is programming [_2].',
        'Steffen',
        'Perl',
    ),
    $loc->maketext(
        '[quant,_1,shelf,shelves]',
        1,
    ),
    $loc->maketext(
        '[quant,_1,shelf,shelves]',
        2,
    ),
    $loc->maketext_p(
        'maskulin',
        'Dear',
    ),
    $loc->maketext_p(
        'maskulin',
        'Dear [_1]',
        'Winkler',
    ),
    $loc->maketext_p(
        'better',
        '[*,_1,shelf,shelves]',
        1,
    ),
    $loc->maketext_p(
        'better',
        '[*,_1,shelf,shelves]',
        2,
    ),
    $loc->maketext(
        '[*,_1,shelf,shelves,no shelf]',
        0,
    ),
    $loc->maketext(
        '[*,_1,shelf,shelves,no shelf]',
        1,
    ),
    $loc->maketext(
        '[*,_1,shelf,shelves,no shelf]',
        2,
    );

# $Id: 41_maketext_mo.pl 271 2010-01-16 07:37:06Z steffenw $

__END__

Output:

Das ist ein Text.
Steffen programmiert Perl.
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
1 gutes Regal
2 gute Regale
0 Regale
1 Regal
2 Regale