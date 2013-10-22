#!perl -T ## no critic (TidyCode)

use strict;
use warnings;

our $VERSION = 0;

require Locale::Utils::PlaceholderNamed;

my $numeric_code = sub {
    my $value = shift;

    defined $value
        or return $value;
    # set the , between 3 digits
    while ( $value =~ s{(\d+) (\d{3})}{$1,$2}xms ) {}
    # German nmber format
    $value =~ tr{.,}{,.};

    return $value;
};

my $obj = Locale::Utils::PlaceholderNamed->new(
    strict => 1,
);

for my $value (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_named(
            'foo {plus} bar {plus} baz = {num} items',
            plus => q{+},
            num  => $numeric_code->($value),
    ),
    "\n";
}

$obj->strict(0);

for my $value (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_named(
            'foo {plus} bar {plus} baz = {num} items',
            # also possible as hash reference
            {
                plus => q{+},
                num  => $value,
            },
    ),
    "\n";
}

# $Id$

__END__

Output:

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
