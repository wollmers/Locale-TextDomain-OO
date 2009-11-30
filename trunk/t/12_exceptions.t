#!perl -T

use strict;
use warnings;

use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
}

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de_DE');
my $text_domain = 'test';

my $loc;
throws_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            xxx => 'xxx',
        );
    },
    qr{\A \QUnknown parameter: xxx}xms,
    'unknown parameter',
);

throws_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            gettext_package => 'Hopefully::Unknown::Package',
        );
    },
    qr{\QCan't locate Hopefully/Unknown/Package.pm}xms,
    'unknown package',
);

lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            text_domain => $text_domain,
            search_dirs => [qw(./t/LocaleData)],
        );
    },
    'create default object',
);

eq_or_diff(
    $loc->__x(
        '{name} is programming {language}.',
    ),
    '{name} programmiert {language}.',
    '__x without args',
);
