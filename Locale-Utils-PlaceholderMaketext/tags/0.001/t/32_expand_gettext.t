#!perl -T

use strict;
use warnings;

use Test::More tests => 28 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::Utils::PlaceholderMaketext');
}

my $obj = Locale::Utils::PlaceholderMaketext->new;

is_deeply(
    [ $obj->expand_gettext(undef) ],
    [ undef ],
    'undef',
);

eq_or_diff(
    $obj->expand_gettext(
        '%1;%quant(%2,s);%quant(%3,s,p);%quant(%4,s,p,z)',
        undef,
        undef,
        'three',
        '4_234_567.890',
    ),
    ';0 s;0 p;z',
    'no strict',
);

$obj->strict(1);

eq_or_diff(
    $obj->expand_gettext(
        '%1;%2;%3;%4;%quant(%5,s);%quant(%6,s)',
        undef,
        'a',
        3,
        '4234567.890',
        undef,
        'b',
    ),
    '%1;a;3;4234567.890;%quant(%5,s);%quant(%6,s)',
    'strict',
);

my @data = (
    {
        text   => '(1) foo %1 bar %quant(%2,singular) baz %3',
        result => [
            '(1) foo and bar %quant(%2,singular) baz %3',
            '(1) foo and bar 0 singular baz %3',
            '(1) foo and bar 1 singular baz %3',
            '(1) foo and bar 2 singular baz %3',
        ],
    },
    {
        text   => '(2) foo %1 bar %*(%2,singular) baz %3',
        result => [
            '(2) foo and bar %*(%2,singular) baz %3',
            '(2) foo and bar 0 singular baz %3',
            '(2) foo and bar 1 singular baz %3',
            '(2) foo and bar 2 singular baz %3',
        ],
    },
    {
        text   => '(3) foo %1 bar %quant(%2,singular,plural) baz %3',
        result => [
            '(3) foo and bar %quant(%2,singular,plural) baz %3',
            '(3) foo and bar 0 plural baz %3',
            '(3) foo and bar 1 singular baz %3',
            '(3) foo and bar 2 plural baz %3',
        ],
    },
    {
        text   => '(4) foo %1 bar %*(%2,singular,plural) baz %3',
        result => [
            '(4) foo and bar %*(%2,singular,plural) baz %3',
            '(4) foo and bar 0 plural baz %3',
            '(4) foo and bar 1 singular baz %3',
            '(4) foo and bar 2 plural baz %3',
        ],
    },
    {
        text   => '(5) foo %1 bar %quant(%2,singular,plural,zero) baz %3',
        result => [
            '(5) foo and bar %quant(%2,singular,plural,zero) baz %3',
            '(5) foo and bar zero baz %3',
            '(5) foo and bar 1 singular baz %3',
            '(5) foo and bar 2 plural baz %3',
        ],
    },
    {
        text   => '(6) foo %1 bar %*(%2,singular,plural,zero) baz %3',
        result => [
            '(6) foo and bar %*(%2,singular,plural,zero) baz %3',
            '(6) foo and bar zero baz %3',
            '(6) foo and bar 1 singular baz %3',
            '(6) foo and bar 2 plural baz %3',
        ],
    },
);

for my $data (@data) {
    my $index = 0;
    for my $number (undef, 0 .. 2) {
        my $defined_number
            = defined $number
            ? $number
            : 'undef';
        eq_or_diff(
            $obj->expand_gettext(
                $data->{text},
                'and',
                $number,
            ),
            $data->{result}->[$index++],
            "'$data->{text}', 'and', $defined_number",
        );
    }
}
