#!perl -T

use strict;
use warnings;
use utf8;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
use Encode qw(encode_utf8 decode_utf8);
require DBD::PO::Locale::PO;
require Locale::TextDomain::OO;
require Locale::Messages::OO::Struct;

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test';

my $loc = Locale::TextDomain::OO->new(
    gettext_object => Locale::Messages::OO::Struct->new(\my %struct),
    text_domain    => $text_domain,
    search_dirs    => [qw(./t/LocaleData)],
    input_filter   => \&encode_utf8,
    filter         => \&decode_utf8,
);

# find the database for the expected language
my $file_path = $loc->get_file_path($text_domain, '.po');

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

# all unicode chars encode to UTF-8
binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

# run all translations
() = print map {"$_\n"}
    $loc->__(
        'book',
    ),
    $loc->__(
        '§ book',
    );

# $Id$

__END__

Output:

книга
§ книга
