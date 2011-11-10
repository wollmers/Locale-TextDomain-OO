#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::Utils::PlaceholderMaketext;

# code to format numeric values
my $formatter_code = sub {
    my ($value, $type) = @_; # $function_name not used

    $type eq 'numeric'
        or return $value;
    # set the , between 3 digits
    while ( $value =~ s{(\d+) (\d{3})}{$1,$2}xms ) {}
    # German number format
    $value =~ tr{.,}{,.};

    return $value;
};

my $obj = Locale::Utils::PlaceholderMaketext->new;

# no strict
# undef converted to q{}
() = print
    $obj->expand_maketext(
        'foo [_1] bar',
        undef,
    ),
    "\n";

# no strict
# undef converted to 0
() = print
    $obj->expand_maketext(
        'bar [quant,_1,singular,plural,zero] baz',
        undef,
    ),
    "\n";

$obj->strict(1);

for (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_maketext(
            'foo [_1] bar [quant,_2,singular,plural,zero] baz',
            # same placeholder for _1 and _2
            $_,
            $_,
        ),
        "\n";
}

# formatted numeric
$obj->formatter_code($formatter_code);

for (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_maketext(
            # same placeholder for _1 and _2
            'foo [_1] bar [*,_2,singular,plural,zero] baz',
            $_,
            $_,
        ),
        "\n";
}

# $Id:$

__END__

Output:

foo  bar
bar zero baz
foo [_1] bar [quant,_2,singular,plural,zero] baz
foo 0 bar zero baz
foo 1 bar 1 singular baz
foo 2 bar 2 plural baz
foo 3234567.890 bar 3234567.890 plural baz
foo 4234567.89 bar 4234567.89 plural baz
foo [_1] bar [*,_2,singular,plural,zero] baz
foo 0 bar zero baz
foo 1 bar 1 singular baz
foo 2 bar 2 plural baz
foo 3.234.567,890 bar 3.234.567,890 plural baz
foo 4.234.567,89 bar 4.234.567,89 plural baz
