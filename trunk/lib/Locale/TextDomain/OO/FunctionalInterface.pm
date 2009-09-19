package Locale::TextDomain::OO::FunctionalInterface;

use strict;
use warnings;

our $VERSION = '0.01';

use Perl6::Export::Attrs;

my @methods = qw(
    __
    __x {
    __n
    __nx
    __p
    __px
    __np
    __npx
    N__
    N__x
    N__n
    N__nx
    N__p
    N__px
    N__np
    N__npx
    maketext
    maketext_p
);

sub bind_object :Export(:DEFAULT) {
    my $object = shift;

    my $caller = caller;

    METHOD:
    for my $method (@methods) {
        $object->can($method)
            or next METHOD;
        no strict qw(refs); ## no critic (NoStrict)
        no warnings qw(redefine); ## no critic (NoWarnings)
        *{"$caller\::$method"} = sub {
            return $object->$method(@_);
        };
    }

    return;
};

1;

__END__

=head1 NAME

Locale::TextDomain::OO::FunctionalInterface - call object methods as funktion

$Id$

$HeadURL$

=head1 VERSION

0.01

=head1 DESCRIPTION

This module wraps the object and allows to call a method as function.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::FunctionalInterface;

or

    use Locale::TextDomain::OO::FunctionalInterface qw(bind_object);

=head1 SUBROUTINES/METHODS

=head2 sub bind_object

    $loc = Locale::TextDomain::OO->new(...);
    bind_object($loc);

or

    $loc = Locale::TextDomain::OO::Maketext->new(...);
    bind_object($loc);

=head2 Translating subs

=head3 maketext

    print maketext(
        'Hello World!',
    );

=head3 maketext_p (allows the context)

    print maketext_p (
        'time',
        'to',
    );

=head1 EXAMPLE

Inside of this Distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Perl6::Export::Attrs>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO>

L<Locale::TextDomain::OO::Maketext>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut