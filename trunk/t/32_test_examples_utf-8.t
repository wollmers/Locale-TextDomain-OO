#!perl

use strict;
use warnings;
use utf8; # ﻿

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 1);

my @data = (
    {
        test   => '01_locale_textdomian_utf-8',
        path   => 'example',
        script => '-I../lib -T 01_locale_textdomian_utf-8.pl',
        result => <<'EOT',
книга
§ книга
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
