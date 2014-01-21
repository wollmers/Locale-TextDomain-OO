package Locale::TextDomain::OO::Lexicon::Role::ExtractHeader; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use English qw(-no_match_vars $EVAL_ERROR);
use Moo::Role;
require Safe;
use namespace::autoclean;

our $VERSION = '1.006';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
);

sub _perlify_plural_forms_ref {
    my ($self, $plural_forms_ref) = @_;

    ${$plural_forms_ref} =~ s{ \b ( nplurals | plural | n ) \b }{\$$1}xmsg;

    return;
}

sub _nplurals {
    my ($self, $plural_forms) = @_;

    $self->_perlify_plural_forms_ref(\$plural_forms);
    my $code = <<"EOC";
        my \$n = 0;
        my (\$nplurals, \$plural);
        $plural_forms;
        \$nplurals;
EOC
    my $nplurals = Safe->new->reval($code)
        or confess "Code of Plural-Forms $plural_forms is not safe, $EVAL_ERROR";

    return $nplurals;
}

sub _plural {
    my ($self, $plural_forms) = @_;

    return $plural_forms =~ m{ \b plural= ( [^;\n] ) }xms;
}

sub _plural_code {
    my ($self, $plural_forms) = @_;

    $self->_perlify_plural_forms_ref(\$plural_forms);
    my $code = <<"EOC";
        sub {
            my \$n = shift;

            my (\$nplurals, \$plural);
            $plural_forms;

            return 0 + \$plural;
        }
EOC
    my $code_ref = Safe->new->reval($code)
        or confess "Code $plural_forms is not safe, $EVAL_ERROR";

    return $code_ref;
}

sub extract_header_msgstr {
    my ($self, $header_msgstr) = @_;

    ## no critic (ComplexRegexes)
    my ( $plural_forms ) = $header_msgstr =~ m{
        ^
        Plural-Forms:
        [ ]*
        (
            nplurals [ ]* [=] [ ]* \d+   [ ]* [;]
            [ ]*
            plural   [ ]* [=] [ ]* [^;\n]+ [ ]* [;]?
            [ ]*
        )
        $
    }xms
        or confess 'Plural-Forms not found in header';
    ## use critic (ComplexRegexes)
    my ( $charset ) = $header_msgstr =~ m{
        ^
        Content-Type:
        [^;]+ [;] [ ]*
        charset [ ]* = [ ]*
        ( [^ ]+ )
        [ ]*
        $
    }xms
        or confess 'Content-Type with charset not found in header';
    my ( $multiplural_nplurals ) = $header_msgstr =~ m{
        ^ X-Multiplural-Nplurals: [ ]* ( \d+ ) [ ]* $
    }xms;

    return {(
        nplurals    => $self->_nplurals($plural_forms),
        plural      => $self->_plural($plural_forms),
        plural_code => $self->_plural_code($plural_forms),
        charset     => $charset,
        (
            $multiplural_nplurals
            ? ( multiplural_nplurals => $multiplural_nplurals )
            : ()
        ),
    )};
}

sub message_array_to_hash {
    my ($self, $messages_ref) = @_;

    return {
        map { ## no critic (ComplexMappings)
            my ( $msgctxt, $msgid, $msgid_plural )
                = delete @{$_}{ qw( msgctxt msgid msgid_plural ) };
            my $msg_key = join $self->msg_key_separator, (
                ( defined $msgctxt      ? $msgctxt      : q{} ),
                ( defined $msgid        ? $msgid        : q{} ),
                ( defined $msgid_plural ? $msgid_plural : ()  ),
            );
            ( $msg_key => $_ );
        } @{$messages_ref}
    };
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::Role::ExtractHeader - Gettext header extractor

$Id$

$HeadURL$

=head1 VERSION

1.006

=head1 DESCRIPTION

This module is extracting charset and plural date from gettext header.

=head1 SYNOPSIS

    with qw(
        Locale::TextDomain::OO::Lexicon::Role::ExtractHeader
    );

=head1 SUBROUTINES/METHODS

=head2 method extract_header_msgstr

    $hash_ref = $self->extract_header_msgstr($header_msgstr);

That hash_ref contains:

    nplurals    => $count_of_plural_forms,
    plural      => $the_original_formula,
    plural_code => $code_ref_to_select_the_right_plural_form,
    charset     => $charset,

=head2 method message_array_to_hash

Transformation the array of messages to a faster accessable hash

    $message_ref = $self->message_array_to_hash($messages_ref);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<English|English>

L<Moo::Role|Moo::Role>

L<Safe|Safe>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Lexicon::Role::Constants|Locale::TextDomain::OO::Lexicon::Role::Constants>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 - 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
