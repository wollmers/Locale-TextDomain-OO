package Locale::TextDomain::OO::TiedInterface; ## no critic (TidyCode)

use strict;
use warnings;

our $VERSION = '1.000';

use Carp qw(confess);
use Tie::Sub;

my %method_name = map { $_ => undef } qw(
    __begin_d
    __begin_c
    __begin_dc
    __end_d
    __end_c
    __end_dc
    __
    __x
    __n
    __nx
    __p
    __px
    __np
    __npx
    __d
    __dx
    __dn
    __dnx
    __dp
    __dpx
    __dnp
    __dnpx
    __c
    __cx
    __cn
    __cnx
    __cp
    __cpx
    __cnp
    __cnpx
    __dc
    __dcx
    __dcn
    __dcnx
    __dcp
    __dcpx
    __dcnp
    __dcnpx
    N__
    N__x
    N__n
    N__nx
    N__p
    N__px
    N__np
    N__npx
    N__d
    N__dx
    N__dn
    N__dnx
    N__dp
    N__dpx
    N__dnp
    N__dnpx
    N__c
    N__cx
    N__cn
    N__cnx
    N__cp
    N__cpx
    N__cnp
    N__cnpx
    N__dc
    N__dcx
    N__dcn
    N__dcnx
    N__dcp
    N__dcpx
    N__dcnp
    N__dcnpx
    maketext
    maketext_p
    loc
    loc_p
    localize
    localize_p
    Nmaketext
    Nmaketext_p
    Nloc
    Nloc_p
    Nlocalize
    Nlocalize_p
);

our $loc_ref = do { my $loc; \$loc }; ## no critic(PackageVars)

sub import {
    my (undef, @imports) = @_;

    if (! @imports) {
        @imports = (
            qw($loc_ref),
            map { ("\%$_", "\$$_") } keys %method_name,
        );
    }

    my $caller  = caller;
    my $package = __PACKAGE__;

    IMPORT:
    for my $import (@imports) {
        defined $import
            or confess 'An undefined value is not a variable name';
        if ($import eq '$loc_ref') { ## no critic (InterpolationOfMetachars)
            no strict qw(refs);       ## no critic (NoStrict)
            no warnings qw(redefine); ## no critic (NoWarnings)
            *{"$caller\::loc_ref"} = \$loc_ref;
            next IMPORT;
        }
        (my $method = $import) =~ s{\A (?: (\$) | % )}{}xms
            or confess qq{"$import" is not a hash or a hash reference};
        my $is_ref = $1;
        exists $method_name{$method}
            or confess qq{"$import" is not exported};
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
                return [ ${$loc_ref}->$method(@_) ];
            }
            : sub {
                return ${$loc_ref}->$method(@_);
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

$Id: TiedInterface.pm 268 2010-01-11 09:05:18Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/tags/0.07/lib/Locale/TextDomain/OO/TiedInterface.pm $

=head1 VERSION

1.000

=head1 DESCRIPTION

This module wraps the object into a tied hash
and allows to call a method as fetch hash.

=head1 SYNOPSIS

import all

    use Locale::TextDomain::OO;
    use Locale::TextDomain::OO::TiedInterface $loc_ref;
    ${loc_ref} = Locale::TextDomain::OO->new(
        ...
    );

or import only the given variables, as example all

    use Locale::TextDomain::OO;
    use Locale::TextDomain::OO::TiedInterface $loc_ref, qw(
        %__begin_d
        %__begin_c
        %__begin_dc
        %__end_d
        %__end_c
        %__end_dc
        %__
        %__x
        %__n
        %__nx
        %__p
        %__px
        %__np
        %__npx
        %__d
        %__dx
        %__dn
        %__dnx
        %__dp
        %__dpx
        %__dnp
        %__dnpx
        %__c
        %__cx
        %__cn
        %__cnx
        %__cp
        %__cpx
        %__cnp
        %__cnpx
        %__dc
        %__dcx
        %__dcn
        %__dcnx
        %__dcp
        %__dcpx
        %__dcnp
        %__dcnpx
        %N__
        %N__x
        %N__n
        %N__nx
        %N__p
        %N__px
        %N__np
        %N__npx
        %N__d
        %N__dx
        %N__dn
        %N__dnx
        %N__dp
        %N__dpx
        %N__dnp
        %N__dnpx
        %N__c
        %N__cx
        %N__cn
        %N__cnx
        %N__cp
        %N__cpx
        %N__cnp
        %N__cnpx
        %N__dc
        %N__dcx
        %N__dcn
        %N__dcnx
        %N__dcp
        %N__dcpx
        %N__dcnp
        %N__dcnpx
        %maketext
        %maketext_p
        %loc
        %loc_p
        %localize
        %localize_p
        %Nmaketext
        %Nmaketext_p
        %Nloc
        %Nloc_p
        %Nlocalize
        %Nlocalize_p
        $__begin_d
        $__begin_c
        $__begin_dc
        $__end_d
        $__end_c
        $__end_dc
        $__
        $__x
        $__n
        $__nx
        $__p
        $__px
        $__np
        $__npx
        $__d
        $__dx
        $__dn
        $__dnx
        $__dp
        $__dpx
        $__dnp
        $__dnpx
        $__c
        $__cx
        $__cn
        $__cnx
        $__cp
        $__cpx
        $__cnp
        $__cnpx
        $__dc
        $__dcx
        $__dcn
        $__dcnx
        $__dcp
        $__dcpx
        $__dcnp
        $__dcnpx
        $N__
        $N__x
        $N__n
        $N__nx
        $N__p
        $N__px
        $N__np
        $N__npx
        $N__d
        $N__dx
        $N__dn
        $N__dnx
        $N__dp
        $N__dpx
        $N__dnp
        $N__dnpx
        $N__c
        $N__cx
        $N__cn
        $N__cnx
        $N__cp
        $N__cpx
        $N__cnp
        $N__cnpx
        $N__dc
        $N__dcx
        $N__dcn
        $N__dcnx
        $N__dcp
        $N__dcpx
        $N__dcnp
        $N__dcnpx
        $maketext
        $maketext_p
        $loc
        $loc_p
        $localize
        $localize_p
        $Nmaketext
        $Nmaketext_p
        $Nloc
        $Nloc_p
        $Nlocalize
        $Nlocalize_p
    );
    ${loc_ref} = Locale::TextDomain::OO->new(
        ...
    );

=head1 SUBROUTINES/METHODS

none

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<Tie::Sub|Tie::Sub>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 - 2013,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
