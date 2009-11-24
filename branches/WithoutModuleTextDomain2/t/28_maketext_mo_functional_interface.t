#!perl -T

use strict;
use warnings;

use Test::More tests => 6 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO::Maketext');
    use_ok('Locale::TextDomain::OO::FunctionalInterface');
}

{
    my $loc;

    lives_ok(
        sub {
            $loc = Locale::TextDomain::OO::Maketext->new(
                language    => 'de_DE',
                text_domain => 'test_maketext',
                search_dirs => [qw(./t/LocaleData/)],
            );
        },
        'create maketext like object',
    );

    lives_ok(
        sub {
            bind_object($loc);
        },
        'bind object',
    );
}

# run all translations
eq_or_diff(
    maketext(
        'This is a text.',
    ),
    'Das ist ein Text.',
    'maketext like __',
);

eq_or_diff(
    maketext_p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter Herr',
    'maketext like __p',
);
