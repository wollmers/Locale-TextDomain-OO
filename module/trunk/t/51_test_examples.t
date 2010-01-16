#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 8);

my @data = (
    {
        test   => '11_gettext_mo',
        path   => 'example',
        script => '-I../lib -T 11_gettext_mo.pl',
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
        test   => '14_N__',
        path   => 'example',
        script => '-I../lib -T 14_N__.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
Einzahl
1 Regal
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
1 gutes Regal
EOT
    },
    {
        test   => '22_gettext_mo_functional_interface',
        path   => 'example',
        script => '-I../lib -T 22_gettext_mo_functional_interface.pl',
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
        test   => '23_gettext_mo_tied_interface',
        path   => 'example',
        script => '-I../lib -T 23_gettext_mo_tied_interface.pl',
        result => <<'EOT',
Das ist ein Text.
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
        test   => '31_gettext_struct_from_locale_po',
        path   => 'example',
        script => '-I../lib -T 31_gettext_struct_from_locale_po.pl',
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
        test   => '32_gettext_struct_from_dbd_po',
        path   => 'example',
        script => '-I../lib -T 32_gettext_struct_from_dbd_po.pl',
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
        test   => '41_maketext_mo',
        path   => 'example',
        script => '-I../lib -T 41_maketext_mo.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
1 gutes Regal
2 gute Regale
0 Regale
1 Regal
2 Regale
EOT
    },
    {
        test   => '42_maketext_mo_style_gettext',
        path   => 'example',
        script => '-I../lib -T 42_maketext_mo_style_gettext.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
1 gutes Regal
2 gute Regale
0 Regale
1 Regal
2 Regale
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