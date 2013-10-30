package Locale::TextDomain::OO::Translator; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use Locale::TextDomain::OO::Singleton::Lexicon;
use Moo;
use MooX::StrictConstructor;
use MooX::Types::MooseLike::Base qw(Str);
use namespace::autoclean;

our $VERSION = '1.000';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
    Locale::TextDomain::OO::Role::Logger
);

sub load_plugins {
    my ( $class, @args ) = @_;

    my %arg_of = @args == 1 ? %{ $args[0] } : @args;
    my $plugins = delete $arg_of{plugins};
    if ( $plugins ) {
        ref $plugins eq 'ARRAY'
            or confess 'Attribute plugins expected as ArrayRef';
        for my $plugin ( @{$plugins} ) {
            my $package = ( 0 == index $plugin, q{+} )
                ? $plugin
                : "Locale::TextDomain::OO::Plugin::$plugin";
            with $package;
        }
    }

    return \%arg_of;
}

has language => (
    is      => 'rw',
    isa     => Str,
    default => 'i-default',
);

has category => (
    is      => 'rw',
    isa     => Str,
    default => q{},
);

has domain => (
    is      => 'rw',
    isa     => Str,
    default => q{},
);

has filter => (
    is  => 'rw',
    isa => sub {
        my $arg = shift;
        # Undef
        defined $arg
            or return;
        # CodeRef
        ref $arg eq 'CODE'
            and return;
        confess "$arg is not Undef or CodeRef";
    },
);

sub translate { ## no critic (ExcessComplexity ManyArgs)
    my ($self, $msgctxt, $msgid, $msgid_plural, $count, $is_n) = @_;

    my $lexicon_key = join $self->lexicon_key_separator, (
        $self->language,
        $self->category,
        $self->domain,
    );
    my $lexicon = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;
    $lexicon = exists $lexicon->{$lexicon_key}
        ? $lexicon->{$lexicon_key}
        : ();

    my $msg_key = join $self->msg_key_separator, (
        ( defined $msgctxt      ? $msgctxt      : q{} ),
        ( defined $msgid        ? $msgid        : q{} ),
        ( defined $msgid_plural ? $msgid_plural : ()  ),
    );
    if ( $is_n ) {
        my $plural_code
            = $lexicon->{ $self->msg_key_separator }->{plural_code}
            || confess qq{Plural-Forms not found in lexicon "$lexicon_key"};
        my $index
            = $plural_code->($count);
        my $msgstr_plural = exists $lexicon->{$msg_key}
            ? $lexicon->{$msg_key}->{msgstr_plural}->[$index]
            : ();
        if ( ! defined $msgstr_plural ) { # fallback
            $msgstr_plural = $index
                ? $msgid_plural
                : $msgid;
            my $text = $lexicon
                ? qq{Using lexicon "$lexicon_key".}
                : qq{Lexicon "$lexicon_key" not found.};
            $self->logger
                and $lexicon
                    ? $self->logger->( qq{Using lexicon "$lexicon_key".} )
                    : $self->logger->( qq{Lexicon "$lexicon_key" not found.} );
            $self->logger
                and $self->logger->(
                    sprintf
                        'msgstr_plural not found for for msgctxt=%s, msgid=%s, msgid_plural=%s.',
                        ( defined $msgctxt      ? qq{"$msgctxt"}      : 'undef' ),
                        ( defined $msgid        ? qq{"$msgid"}        : 'undef' ),
                        ( defined $msgid_plural ? qq{"$msgid_plural"} : 'undef' ),
                );
        }
        return $msgstr_plural;
    }
    my $msgstr = exists $lexicon->{$msg_key}
        ? $lexicon->{$msg_key}->{msgstr}
        : ();
    if ( ! defined $msgstr ) { # fallback
        $msgstr = $msgid;
        my $text = $lexicon
            ? qq{Using lexicon "$lexicon_key".}
            : qq{Lexicon "$lexicon_key" not found.};
        $self->logger
            and $self->logger->(
                sprintf
                    '%s msgstr not found for msgctxt=%s, msgid=%s.',
                    $text,
                    ( defined $msgctxt ? qq{"$msgctxt"} : 'undef' ),
                    ( defined $msgid   ? qq{"$msgid"}   : 'undef' ),
            );
    }

    return $msgstr;
}

sub run_filter {
    my ( $self, $translation_ref ) = @_;

    $self->filter
        or return $self;
    $self->filter->($self, $translation_ref);

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Translator - Translator class

$Id$

$HeadURL$

=head1 VERSION

1.000

=head1 DESCRIPTION

This is the translator class. Extend that class with plugins (Roles).

=head1 SYNOPSIS

    require Locale::TextDomain::OO::Translator;
    Locale::TextDomain::OO::Translator->new(
        Locale::TextDomain::OO::Translator->load_plugins,
    );

=head1 SUBROUTINES/METHODS

=head2 class method load_plugins

Called before new to load the plugins
    $hash_ref = Locale::TextDomain::OO::Translator->load_plugins;

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Read the file README there.
Then run the *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<Carp|Carp>

L<Locale::TextDomain::OO::Singleton::Lexicon|Locale::TextDomain::OO::Singleton::Lexicon>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

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
