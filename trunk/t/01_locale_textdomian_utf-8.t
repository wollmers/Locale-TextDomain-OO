#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 6 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Encode qw(encode_utf8 decode_utf8);

BEGIN {
    require_ok('Locale::TextDomain');
    use_ok('Locale::Messages', qw(bind_textdomain_filter));
}

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test';

lives_ok(
    sub {
        Locale::TextDomain->import( $text_domain, qw(./t/LocaleData) );
    },
    'bind mo file',
);

lives_ok(
    sub {
        bind_textdomain_filter($text_domain, \&decode_utf8);
    },
    'bind output filter',
);

eq_or_diff(
    __(
        'book',
    ),
    'книга',
    'UTF-8 in msgstr only',
);

eq_or_diff(
    __(
        encode_utf8('§ book'),
    ),
    '§ книга',
    'UTF-8 at all',
);
