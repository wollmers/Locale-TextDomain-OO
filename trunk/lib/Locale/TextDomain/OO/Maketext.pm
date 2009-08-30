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

    $style =~ m{\A (?: maketext | gettext ) \z}xms
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
        if (defined $4) { # replace only
            my $value = $args[$4 - 1];
            return defined $value ? $value : q{};
        }
        if (defined $1) { # quant
            my $value    = $args[$1 - 1];
            my $singular = $2;
            my $plural   = $3;
            $value = defined $value ? $value : q{};
            no warnings qw(uninitialized numeric);
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
	   (?:
	       \% (?: quant | \* )
	       \(
	       \% (\d+)              # $1: _n
	       , ( [^,]* )           # $2: singular
	       (?: , ( [^,]* ) )?    # $3: plural
	       (?: , [^,]* )?        # ignore zero
	       \)
	       |
	       \% (\d+)              # $4: _n
	   )
        }
        {
            $replace->()
        }xmsge;
    }
    else {
        $translation =~ s{
	   \[ (?:
	       (?: quant | \* )
	       , _ (\d+)            # $1: _n
	       , ( [^,]* )          # $2: singular
	       (?: , ( [^,]* ) )?   # $3: plural
	       (?: , [^,]* )?       # ignore zero
	       |
	       _ (\d+)              # $4: _n
	   ) \]
        }
        {
            $replace->()
        }xmsge;
    }

    return $translation;
}

sub _maketext2gettext {
    my ($self, $text) = @_;

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

    return $self->_expand_maketext(
        $self->_get_sub('dgettext')->(
            $self->_get_text_domain(),
            $self->_is_gettext_style()
            ? $self->_maketext2gettext($msgid)
            : $msgid,
        ),
        @args,
    );
}

sub maketext_p {
    my ($self, $msgctxt, $msgid, @args) = @_;

    return $self->_expand_maketext(
        $self->_get_sub('dpgettext')->(
            $self->_get_text_domain(),
            $msgctxt,
            $self->_is_gettext_style()
            ? $self->_maketext2gettext($msgid)
            : $msgid,
        ),
        @args,
    );
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

See method new at L<Locale::TextDomain::OO>

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


=head3 maketext_p (allow context)

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