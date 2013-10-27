package Locale::TextDomain::OO::Plugin::Expand::Maketext::Localize;

use Moo::Role;
use namespace::autoclean;

our $VERSION = '1.000';

BEGIN {
    with qw(
        Locale::TextDomain::OO::Plugin::Expand::Maketext
    );

    no warnings qw(redefine); ## no critic (NoWarnings)
    *localize    = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::maketext;
    *localize_p  = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::maketext_p;
    *Nlocalize   = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::Nmaketext;
    *Nlocalize_p = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::Nmaketext_p;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Maketext - An additional maketext interface for Message Translation

$Id: Maketext.pm 255 2009-12-29 14:01:31Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Maketext.pm $

=head1 VERSION

0.03

=head1 DESCRIPTION

This module provides an additional maketext interface like L<Locale::Maketext::Simple>
for L<Locale::TextDomain:OO>
to port projects from Locale::Maketext.

=head1 SYNOPSIS

    require Locale::TextDomain::OO::Maketext;

=head1 SUBROUTINES/METHODS

=head2 method new

See method new at L<Locale::TextDomain::OO>.

There is an extra parameter 'style'.

    my $loc = Locale::TextDomain::OO::Maketext->new(
        ...
        style => 'gettext',
        ...
    );

Style 'gettext' allows to use gettext like data.

 %1
 %quant(%1,singular,plural)
 %*(%1,singular,plural)

instead of

 [_1]
 [quant,_1,singular,plural]
 [*,_1,singular,plural]

=head2 Translating methods

=head3 maketext

This method includes the expansion as 'quant' or '*'.
This method ignores zero plural forms.

    print $loc->maketext(
        'Hello World!',
    );

    print $loc->maketext(
        'Hello [_1]!',
        'Steffen',
    );

    print $loc->maketext(
        '[quant,_1,file read,files read]',
        $num_files,
    );


=head3 maketext_p (allows the context)

    print $loc->maketext_p (
        'time',
        'to',
    );

    print $loc->maketext_p (
        'destination',
        'to',
    );

    print $loc->maketext_p (
        'destination',
        'from [_1] to [_2]',
        'Chemnitz',
        'Erlangen',
    );

    print $loc->maketext_p(
        'maskulin',
        'Mr. [_1] has [*,_2,book,books].',
        $name,
        $books,
    );

=head3 Nmaketext, Nmaketext_p

The extractor looks for C<maketext('...')>
and has no problem with C<<$loc->Nmaketext('...')>>.

This is the idea of the N-Methods.

    $loc->Nmaketext('...');

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error message in case of unknown parameters.

 Unknown parameter: ...

Error message at calculation plural forms.

 Plural-Forms are not defined

 Code of Plural-Forms ... is not safe, ...

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

version

parent

L<Locale::TextDomain::OO>

Carp

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO>

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
