#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Encode qw(encode_utf8 decode_utf8);
require DBD::PO::Locale::PO;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::MessagesStruct');
}

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test';

my ($loc, %struct);
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            gettext_object => Locale::TextDomain::OO::MessagesStruct->new(\%struct),
            text_domain    => $text_domain,
            search_dirs    => [qw(./t/LocaleData)],
            input_filter   => \&encode_utf8,
            filter         => \&decode_utf8,
        );
    },
    'create extended object',
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

# run all translations
eq_or_diff(
    $loc->__(
        'book',
    ),
    'книга',
    '__',
);

eq_or_diff(
    $loc->__(
        '§ book',
    ),
    '§ книга',
    '__ umlaut',
);
