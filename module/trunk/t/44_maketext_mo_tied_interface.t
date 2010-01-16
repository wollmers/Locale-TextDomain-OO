#!perl -T

use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO::Maketext');
    use_ok('Locale::TextDomain::OO::TiedInterface', qw($loc %maketext $maketext %maketext_p $maketext_p));
}

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO::Maketext
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'test_maketext';

lives_ok(
    sub {
        $loc = Locale::TextDomain::OO::Maketext->new(
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
        );
    },
    'create maketext like object',
);

# run all translations
eq_or_diff(
    $maketext{'This is a text.'},
    'Das ist ein Text.',
    '%maketext like __, string',
);
eq_or_diff(
    $maketext->{'This is a text.'},
    'Das ist ein Text.',
    '$maketext like __, string',
);

eq_or_diff(
    $maketext{[
        'This is a text.',
    ]},
    'Das ist ein Text.',
    '%maketext like __, arrayref',
);
eq_or_diff(
    $maketext->{[
        'This is a text.',
    ]},
    'Das ist ein Text.',
    '$maketext like __, arrayref',
);

eq_or_diff(
    $maketext_p{[
        'maskulin',
        'Dear',
    ]},
    'Sehr geehrter Herr',
    '%maketext like __p',
);
eq_or_diff(
    $maketext_p->{[
        'maskulin',
        'Dear',
    ]},
    'Sehr geehrter Herr',
    '$maketext like __p',
);