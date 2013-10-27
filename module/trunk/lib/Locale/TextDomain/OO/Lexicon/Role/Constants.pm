package Locale::TextDomain::OO::Lexicon::Role::Constants;

use strict;
use warnings;
use Moo::Role;
use charnames qw(:full);
use namespace::autoclean;

our $VERSION = '1.000';

sub lexicon_key_separator {
    return q{:};
}

sub msg_key_separator {
    return "\N{END OF TRANSMISSION}";
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::Role::Constants - Lexicon constants

$Id: Maketext.pm 255 2009-12-29 14:01:31Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Maketext.pm $

=head1 VERSION

1.000

=head1 DESCRIPTION

This role provides lexicon constants.

=head1 SYNOPSIS

    with qw(
        Locale::TextDomain::OO::Lexicon::Role::Constants
    );

=head1 SUBROUTINES/METHODS

=head2 method lexicon_key_separator
    
    $separator = $self->lexicon_key_separator;

=head2 method key_separator

    $separator = $self->key_separator;

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo::Role|Moo::Role>

L<charnames|charnames>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
