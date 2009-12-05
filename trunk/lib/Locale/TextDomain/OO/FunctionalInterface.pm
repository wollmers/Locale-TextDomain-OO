package Locale::TextDomain::OO::FunctionalInterface;

use strict;
use warnings;

use version; our $VERSION = qv('0.02');

use Carp qw(croak);
use Perl6::Export::Attrs;

my %method_name = map { $_ => undef } qw(
    __
    __x
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
    my ($object, @methods) = @_;

    if (! @methods) {
        @methods = grep { $object->can($_) } keys %method_name;
    }

    my $caller = caller;

    for my $method (@methods) {
        defined $method
            or croak 'An undefined value is not a method name';
        exists $method_name{$method}
            or croak qq{Method "$method" is not a translation method};
        $object->can($method)
            or croak qq{Object has no method named "$method"};
        no strict qw(refs);       ## no critic (NoStrict)
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

Locale::TextDomain::OO::FunctionalInterface - Call object methods as function

$Id$

$HeadURL$

=head1 VERSION

0.02

=head1 DESCRIPTION

This module wraps the object and allows to call a method as function.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::FunctionalInterface;

or

    use Locale::TextDomain::OO::FunctionalInterface qw(bind_object);

=head1 SUBROUTINES/METHODS

=head2 subroutine bind_object

    $loc = Locale::TextDomain::OO->new(...);

or

    $loc = Locale::TextDomain::OO::Maketext->new(...);

and

    bind_object($loc); # import all possible methods

or

    bind_object($loc, qw(__ __x ...)); # import only the given methods

=head1 EXAMPLE

Inside of this Distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Subroutine bind_object can not bind an undef as method name.

 An undefined value is not a method name

Subroutine bind_object only can bind translating subroutines.

 Method "..." is not a translation method

Subroutine bind_object can not bind a non existing object method.

 Object has no method named "..."

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

Carp

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