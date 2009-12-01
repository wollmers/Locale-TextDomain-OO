#!perl

use strict;
use warnings;
use utf8;

use Test::More tests => 3 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Encode qw(encode decode);

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de');
my $text_domain = 'cp1252';
my $encoding    = 'cp1252';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain  => $text_domain,
            search_dirs  => [qw(./t/LocaleData)],
            # input filter
            input_filter => sub { encode($encoding, shift) },
            # output filter
            filter       => sub { decode($encoding, shift) },
        );
    },
    'create default object',
);

eq_or_diff(
    $loc->__(
        'This are German umlauts: ä ö ü ß Ä Ö Ü.',
    ),
    'Das sind detsche Umlaute: ä ö ü ß Ä Ö Ü.',
    '__'
);