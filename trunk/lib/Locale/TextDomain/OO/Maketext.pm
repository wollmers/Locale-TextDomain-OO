package Locale::TextDomain::OO::Maketext;

use strict;
use warnings;

our $VERSION = '0.01';

use parent qw(Locale::TextDomain::OO);
use Carp qw(croak);

sub new {
    my ($class, %init) = @_;

    my $is_style = exists $init{style};
    my $style    = delete $init{style};
    my $self     = $class->SUPER::new(%init);
    if ($is_style) {
        $self->_set_style($style);
    }

    return $self;
}

sub _set_style {
    my ($self, $style) = @_;

    {
        maketext => 1,
        gettext  => 1,
    }->{$style}
        or croak "$style not allowed at parameter style";
    $self->{style} = $style;

    return $self;
}

sub _is_gettext_style {
    my $self = shift;

    return
        $self->{style}
        && $self->{style} eq 'gettext';
}

sub _expand_maketext {
    my ($self, $translation, @args) = @_;

    my $replace = sub {
        if (defined $5) { # replace only
            my $index = $5 - 1;
            exists $args[$index]
                or return $1;
            my $value = $args[$index];
            return defined $value ? $value : q{};
        }
        if (defined $2) { # quant
            my $index = $2 - 1;
            exists $args[$index]
                or return $1;
            my $value    = $args[$index];
            my $singular = $3;
            my $plural   = $4;
            $value = defined $value ? $value : q{};
            no warnings qw(uninitialized numeric); ## no critic (NoWarnings)
            return
                +( defined $plural && $value == 1 )
                ?(
                    defined $singular
                    ? "$value $singular"
                    : q{}
                )
                : "$value $plural";
        }

        return q{};
    };

    if ( $self->_is_gettext_style() ) {
        $translation =~ s{
            (
                \% (?: quant | \* )
                \(
                \% (\d+)              # $2: _n
                , ( [^,]* )           # $3: singular
                (?: , ( [^,]* ) )?    # $4: plural
                (?: , [^,]* )?        # ignore zero
                \)
                |
                \% (\d+)              # $5: _n
            )
        }
        {
            $replace->()
        }xmsge;
    }
    else {
        $translation =~ s{
            (
                \[ (?:
                    (?: quant | \* )
                    , _ (\d+)            # $2: _n
                    , ( [^,]* )          # $3: singular
                    (?: , ( [^,]* ) )?   # $4: plural
                    (?: , [^,]* )?       # ignore zero
                    |
                    _ (\d+)              # $5: _n
                ) \]
            )
        }
        {
            $replace->()
        }xmsge;
    }

    return $translation;
}

sub _maketext2gettext {
    my (undef, $text) = @_;

    $text =~ s{
        \[ (?:
            ( quant | \* )   # $1: function
            , _ (\d+)        # $2: _n
            , ( [^\]]* )     # $3: args
            |
            _ (\d+)          # $4: _n
        ) \]
    }
    {
        defined $4
        ? "\%$4"
        : "\%$1(\%$2,$3)"
    }xmsge;

    return $text;
}

sub maketext {
    my ($self, $msgid, @args) = @_;

    if ( @args && $self->_is_gettext_style() ) {
        $msgid = $self->_maketext2gettext($msgid);
    }

    $self->_run_input_filter(\$msgid);

    my $translation = $self->_get_sub('dgettext')->(
        $self->_get_text_domain(),
        $msgid,
    );

    $self->_run_output_filter(\$translation);

    if (@args) {
        $translation = $self->_expand_maketext(
            $translation,
            @args,
        );
    }

    return $translation;
}

sub maketext_p {
    my ($self, $msgctxt, $msgid, @args) = @_;

    if ( @args && $self->_is_gettext_style() ) {
        $msgid = $self->_maketext2gettext($msgid);
    }

    $self->_run_input_filter(\$msgctxt, \$msgid);

    my $translation = $self->_get_sub('dpgettext')->(
        $self->_get_text_domain(),
        $msgctxt,
        $msgid,
    );

    $self->_run_output_filter(\$translation);

    if (@args) {
        $translation = $self->_expand_maketext(
            $translation,
            @args,
        );
    }

    return $translation;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Maketext - A maketext interface for Message Translation

$Id$

$HeadURL$

=head1 VERSION

0.01

=head1 DESCRIPTION

This module provides a maketext interface like L<Locale::Maketext::Simple>
for L<Locale::TextDomain:OO>
to move projects from Locale::Maketext to Locale::TextDomain.

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

Style 'gettext' allows use gettext like data.

 %1
 %quant(%1,singular,plural)
 %*(%1,singular,plural)

instead of

 [_1]
 [quant,_1,singular,plural]
 [*,_1,singular,plural]

=head2 Translating methods

=head3 maketext

This method includes expnad like 'quant', '*'.
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

=head1 EXAMPLE

Inside of this Distribution is a directory named example.
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

Carp

Cwd

English

L<I18N::LangTags::Detect>

L<I18N::LangTags>

Safe

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin>

L<Locale::Messages>

L<http://www.gnu.org/software/gettext/manual/gettext.html>

L<http://en.wikipedia.org/wiki/Gettext>

L<http://translate.sourceforge.net/wiki/l10n/pluralforms>

L<http://rassie.org/archives/247> The choice of the right module for the translation.

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
