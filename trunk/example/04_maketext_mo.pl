#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
require Locale::TextDomain::OO::Maketext;

local $ENV{LANGUAGE} = 'de_DE';
my $text_domain      = 'example_04';

my $loc = Locale::TextDomain::OO::Maketext->new(
    text_domain => $text_domain,
    search_dirs => [qw(./LocaleData/)],
);

#binmode STDOUT, ':encoding(utf-8)'
#    or croak "Binmode STDOUT\n$OS_ERROR";

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

# $Id$

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
