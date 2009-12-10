package Locale::TextDomain::OO::TiedInterface;

use strict;
use warnings;

use version; our $VERSION = qv('0.03');

use Carp qw(croak);
use Perl6::Export::Attrs;
use Tie::Sub;

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

sub tie_object :Export(:DEFAULT) {
    my ($object, @attr) = @_;

    while ( my ($method, $ref) = splice @attr, 0, 2 ) {
        defined $method
            or croak 'An undefined value is not a method name';
        exists $method_name{$method}
            or croak qq{Method "$method" is not a translation method};
        $object->can($method)
            or croak qq{Object has no method named "$method"};
        no strict qw(refs);       ## no critic (NoStrict)
        no warnings qw(redefine); ## no critic (NoWarnings)
        tie ## no critic (Ties)
            %{$ref},
            'Tie::Sub',
            ( index $method, 'N' ) == 0
            ? sub {
                return [ $object->$method(@_) ];
            }
            : sub {
                return $object->$method(@_);
            };
    }

    return;
};

1;

__END__

=head1 NAME

Locale::TextDomain::OO::TiedInterface - Call object methods as tied hash

$Id$

$HeadURL$

=head1 VERSION

0.03

=head1 DESCRIPTION

This module wraps the object into a tied hash
and allows to call a method as fetch hash.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::TiedInterface;

or

    use Locale::TextDomain::OO::TiedInterface qw(tie_object);

=head1 SUBROUTINES/METHODS

=head2 subroutine tie_object

    $loc = Locale::TextDomain::OO->new(...);

or

    $loc = Locale::TextDomain::OO::Maketext->new(...);

and

    tie_object(
        $loc,
        {
            # tie a hash
            __  => \my %__,
            __x => \my %__x,
            ...
            # tie a hash reference
            __  => my $__,
            __x => my $__x,
        },
    );

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Subroutine tie_object can not bind an undef as method name.

 An undefined value is not a method name

Subroutine tie_object only can bind translating methods.

 Method "..." is not a translation method

Subroutine tie_object can not bind a non existing object method.

 Object has no method named "..."

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

Carp

L<Perl6::Export::Attrs>

L<Tie::Sub>

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
