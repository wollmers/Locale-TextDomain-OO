#!perl -T

use strict;
use warnings;

use Test::More tests => 7 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::Utils::PlaceholderMaketext');
}

my $obj = Locale::Utils::PlaceholderMaketext->new;

is_deeply(
    [ $obj->maketext_to_gettext(undef) ],
    [ undef ],
    'undef',
);

my @data = (
    [ 
        q{}, 
        q{}, 
        'empty sting',
    ],
    [
        'foo [_1] bar',
        'foo %1 bar',
        'placeholder',
    ],
    [
        'foo [_1] bar [quant,_2,singluar,plural,zero] baz [#,_3]',
        'foo %1 bar %quant(%2,singluar,plural,zero) baz %#(%3)',
        'function quant',
    ],
    [
        'bar [*,_2,singluar,plural] baz',
        'bar %*(%2,singluar,plural) baz',
        'function *',
    ],
    [
        'baz [#,_3]',
        'baz %#(%3)',
        'function #',
    ],
);

for my $data (@data) {
    eq_or_diff(
        $obj->maketext_to_gettext( $data->[0] ),
        @{$data}[ 1, 2 ],
    );
}
