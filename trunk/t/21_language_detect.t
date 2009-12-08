#!perl -T

use strict;
use warnings;

use Test::More tests => 3 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANGUAGE} = 'de';
my $text_domain      = 'test';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain     => $text_domain,
            search_dirs     => [qw(./t/LocaleData)],
            language_detect => sub {
                return 'de';
            },
        );
    },
    'create default object',
);

eq_or_diff(
    $loc->__(
        'This is a text.',
    ),
    'Das ist ein Text.',
    '__',
);