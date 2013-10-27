package Locale::TextDomain::OO::Role::Logger;

use strict;
use warnings;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(CodeRef);
use namespace::autoclean;

our $VERSION = '1.000';

has logger => (
    is  => 'rw',
    isa => CodeRef,
);

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Role::Logger - Provides a logger method

$Id: Maketext.pm 255 2009-12-29 14:01:31Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Maketext.pm $

=head1 VERSION

1.000

=head1 DESCRIPTION

This module provides a logger method for
for L<Locale::TextDomain:OO|Locale::TextDomain:OO>.

=head1 SYNOPSIS

    require Locale::TextDomain::OO;

    my $loc = Locale::TextDomain::OO->new(
        logger => sub {
        },
        ...
    );

=head1 SUBROUTINES/METHODS

=head2 method logger

Store logger code to get some information
what lexicon is used
or why the translation process is using a fallback.

    $log->logger(
        sub {
            my $message = shift;
            ...
            return;
        },
    );

get back

    $code_ref_or_undef = $self->logger;

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

nothing

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo::Role|Moo::Role>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

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
