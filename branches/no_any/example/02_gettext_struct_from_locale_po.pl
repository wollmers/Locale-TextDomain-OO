#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR $EVAL_ERROR);
require DBD::PO::Locale::PO;
require Locale::TextDomain::OO;
require Locale::Messages::OO::Struct;

local $ENV{LANGUAGE} = 'de_DE';
my $text_domain      = 'example_02';

my $loc = Locale::TextDomain::OO->new(
    gettext_object => Locale::Messages::OO::Struct->new(\my %struct),
    text_domain    => $text_domain,
    search_dirs    => [qw(./LocaleData/)],
);

# find the database for the expected language
# here fallback to 'de'
my $file_path = $loc->get_file_path($text_domain, '.po');

binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

my $locale_po = DBD::PO::Locale::PO->new();
my $array_ref = $locale_po->load_file_asarray("$file_path/$text_domain.po");

# header
my $header = ( shift @{$array_ref} )->msgstr();
my ($plural_forms) = $header=~  m{^ Plural-Forms: \s (.*) \n}xms;

# convert array_ref of objects to array_ref of hashes
for my $entry ( @{$array_ref} ) {
    $entry = {
        msgctxt      => scalar $entry->msgctxt(),
        msgid        => scalar $entry->msgid(),
        msgid_plural => scalar $entry->msgid_plural(),
        msgstr       => scalar $entry->msgstr(),
        do {
            my $msgstr_n = $entry->msgstr_n();
            $msgstr_n
            ? (
                map {
                    ( "msgstr_$_" => $msgstr_n->{$_} );
                } keys %{$msgstr_n}
            )
            : ();
        },
    };
}

# build the struct and bind the struct as object to the text domain
%struct = (
    $text_domain => {
        plural_ref => $loc->get_function_ref_plural($plural_forms),
        array_ref  => $array_ref,
    },
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