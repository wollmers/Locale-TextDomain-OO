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

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            language     => 'ru',
            text_domain  => 'test',
            search_dirs  => [qw(./t/LocaleData)],
            input_filter => \&encode_utf8,
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
