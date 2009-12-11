package Locale::TextDomain::OO::TiedInterface;

use strict;
use warnings;

use version; our $VERSION = qv('0.03');

use Carp qw(croak);
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

our $loc; ## no critic(PackageVars)

sub import {
    my (undef, @imports) = @_;

    if (! @imports) {
        @imports = (
            qw($loc),
            map { ("\%$_", "\$$_") } keys %method_name
        );
    }

    my $caller  = caller;
    my $package = __PACKAGE__;

    IMPORT:
    for my $import (@imports) {
        defined $import
            or croak 'An undefined value is not a variable name';
        if ($import eq '$loc') { ## no critic (InterpolationOfMetachars)
            no strict qw(refs);       ## no critic (NoStrict)
            no warnings qw(redefine); ## no critic (NoWarnings)
            *{"$caller\::loc"} = \$loc;
            next IMPORT;
        }
        (my $method = $import) =~ s{\A (?: (\$) | % )}{}xms
            or croak qq{"$import" is not a hash or a hash references};
        my $is_ref = $1;
        exists $method_name{$method}
            or croak qq{Method "$method" is not a translation method};
        {
            no strict qw(refs);       ## no critic (NoStrict)
            no warnings qw(redefine); ## no critic (NoWarnings)
            *{"$caller\::$method"}
                = $is_ref
                ? \${"$package\::$method"}
                : \%{"$package\::$method"};
        }
        my $sub
            = ( index $method, 'N', 0 ) == 0
            ? sub {
                return [ $loc->$method(@_) ];
            }
            : sub {
                return $loc->$method(@_);
            };
        if ($is_ref) {
            no strict qw(refs); ## no critic (NoStrict)
            tie ## no critic (Ties)
                %{ ${$method} },
                'Tie::Sub',
                $sub;
        }
        else {
            no strict qw(refs); ## no critic (NoStrict)
            tie ## no critic (Ties)
                %{$method},
                'Tie::Sub',
                $sub;
        }
    }

    return;
}

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
