#!perl

use strict;
use warnings;
use utf8;

use Test::More tests => 3 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Encode qw(decode_utf8);

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
            filter      => sub {
                my $string = shift;
                return decode_utf8($string);
            },

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