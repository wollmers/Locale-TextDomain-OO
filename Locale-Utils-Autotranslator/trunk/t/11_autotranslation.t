#!perl -T

use strict;
use warnings;

use Test::More tests => 10;
use Test::NoWarnings;
use Test::Differences;

use lib qw(
    D:/build/Locale-TextDomain-OO/module/trunk/lib
    D:/build/DBD/PO/trunk/lib
);

BEGIN {
    require_ok('Locale::Utils::Autotranslator');
    require_ok('DBD::PO::Locale::PO');
}

my $obj = Locale::Utils::Autotranslator
    ->new
    ->translate(
        't/LocaleData/untranslated de.po',
        't/LocaleData/translated de.po',
    );
