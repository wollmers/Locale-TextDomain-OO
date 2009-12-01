#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 5);

my @data = (
    {
        test   => '21_gettext_mo',
        path   => 'example',
        script => '-I../lib -T 21_gettext_mo.pl',
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
        test   => '22_gettext_struct_from_locale_po',
        path   => 'example',
        script => '-I../lib -T 22_gettext_struct_from_locale_po.pl',
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
        test   => '23_gettext_struct_from_dbd_po',
        path   => 'example',
        script => '-I../lib -T 23_gettext_struct_from_dbd_po.pl',
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
        test   => '24_maketext_mo',
        path   => 'example',
        script => '-I../lib -T 24_maketext_mo.pl',
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
        test   => '25_maketext_mo_style_gettext',
        path   => 'example',
        script => '-I../lib -T 25_maketext_mo_style_gettext.pl',
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
