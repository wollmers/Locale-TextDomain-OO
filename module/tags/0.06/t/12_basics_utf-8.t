#!perl

use strict;
use warnings;
use utf8;

use Test::More tests => 4 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Encode qw(encode_utf8 decode_utf8);

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('ru');
my $text_domain = 'test';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain  => $text_domain,
            search_dirs  => [qw(./t/LocaleData)],
            # input filter
            input_filter => \&encode_utf8,
            # output filter
            filter       => \&decode_utf8,
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

eq_or_diff(
    $loc->__(
        '§ book',
    ),
    '§ книга',
    '__',
);
