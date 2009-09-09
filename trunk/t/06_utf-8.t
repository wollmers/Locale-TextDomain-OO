#!perl

use strict;
use warnings;
use utf8;

use Test::More tests => 15 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test_06';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
            codeset     => 'utf-8',
        );
    },
    'create default object',
);

eq_or_diff(
    $loc->__(
        'book',
    ),
    'книга',
    '__',
);