#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 3);

my @data = (
    {
        test   => 'de',
        path   => 'example',
        script => '-I../lib -T 01_gettext_default_mo.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
gute Regale
1 gutes Regal
2 gute Regale
EOT
    },
    {
        test   => 'de',
        path   => 'example',
        script => '-I../lib -T 02_gettext_struct_from_locale_po.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
gute Regale
1 gutes Regal
2 gute Regale
EOT
    },
    {
        test   => 'de',
        path   => 'example',
        script => '-I../lib -T 03_gettext_struct_from_dbd_po.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
gute Regale
1 gutes Regal
2 gute Regale
EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = qx{perl $data->{script} 2>&3};
    chdir($dir);
    eq_or_diff(
        $result,
        $data->{result},
        $data->{test},
    );
}