#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 1);

my @data = (
    {
        test   => '11_calculate_plural_forms',
        path   => 'example',
        script => '-I../lib -T 11_calculate_plural_forms.pl',
        result => <<'EOT',
English:
plural_froms = 'nplurals=2; plural=(n != 1)'
nplurals = 2

The EN plural from from 0 is 1
The EN plural from from 1 is 0
The EN plural from from 2 is 1
Russian:
plural_froms = 'nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 or n%100>=20) ? 1 : 2)'
nplurals = 3

The RU plural from from 0 is 2
The RU plural from from 1 is 0
The RU plural from from 2 is 1
The RU plural from from 5 is 2
The RU plural from from 100 is 2
The RU plural from from 101 is 0
The RU plural from from 102 is 1
The RU plural from from 105 is 2
The RU plural from from 110 is 2
The RU plural from from 111 is 2
The RU plural from from 112 is 2
The RU plural from from 115 is 2
The RU plural from from 120 is 2
The RU plural from from 121 is 0
The RU plural from from 122 is 1
The RU plural from from 125 is 2
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
