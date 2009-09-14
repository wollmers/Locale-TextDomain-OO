#!perl

use strict;
use warnings;
use utf8;

use Test::More tests => 3 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Encode qw(decode);

BEGIN {
    require_ok('Locale::TextDomain');
    use_ok('Locale::Messages', qw(bind_textdomain_filter));
}

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test_06';

lives_ok(
    sub {
        Locale::TextDomain->import( $text_domain, qw(./t/LocaleData) );
    },
    'bind mo file',
);

my $filter = sub {
    my $string = shift;

    die 'filter called';

    return decode('UTF-8', $string);
};

lives_ok(
    sub {
        bind_textdomain_filter($filter);
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
        '§ book',
    ),
    '§ книга',
    'UTF-8 at all',
);
