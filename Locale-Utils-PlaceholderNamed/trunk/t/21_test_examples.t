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
        test   => '01_expand_named',
        path   => 'example',
        script => '-I../lib -T 01_expand_named.pl',
        result => <<'EOT',
foo + bar + baz = {num} items
foo + bar + baz = 0 items
foo + bar + baz = 1 items
foo + bar + baz = 2 items
foo + bar + baz = 3.234.567,890 items
foo + bar + baz = 4.234.567,89 items
foo + bar + baz =  items
foo + bar + baz = 0 items
foo + bar + baz = 1 items
foo + bar + baz = 2 items
foo + bar + baz = 3234567.890 items
foo + bar + baz = 4234567.89 items
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
