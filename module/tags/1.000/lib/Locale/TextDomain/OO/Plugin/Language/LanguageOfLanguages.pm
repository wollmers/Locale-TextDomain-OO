package Locale::TextDomain::OO::Plugin::Language::LanguageOfLanguages; ## no critic (Tidy Code)

use strict;
use warnings;
use Locale::TextDomain::OO::Singleton::Lexicon;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(Str ArrayRef);
use namespace::autoclean;

our $VERSION = '1.000';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
    Locale::TextDomain::OO::Role::Logger
);

requires qw(
    language
    category
    domain
);

has languages => (
    is      => 'rw',
    isa     => ArrayRef[Str],
    trigger => 1,
    lazy    => 1,
    default => sub { [] },
);

sub _trigger_languages { ## no critic (UnusedPrivateSubroutines)
    my ($self, $languages) = @_;

    my $lexicon = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;
    for my $language ( @{$languages} ) {
        for my $key ( keys %{$lexicon} ) {
            my $lexicon_key = join $self->lexicon_key_separator, (
                lc $language,
                $self->category || q{},
                $self->domain   || q{},
            );
            if ( $key eq $lexicon_key ) {
               $self->language( lc $language );
               $self->logger
                   and $self->logger->( qq{Language "\l$language" selected.} );
               return $self;
            }
        }
    }
    $self->language('i-default');

    return $self;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Plugin::Language::LanguageOfLanguages - Select a language of a list

$Id$

$HeadURL$

=head1 VERSION

1.000

=head1 DESCRIPTION

This plugin provides the languages method.
After set of languages it will find and set the first language match in lexicon.
Otherwise language is set to i-default.

=head1 SYNOPSIS

    $loc = Locale::TextDomain::OO->new(
        plugins => [ qw (
            Language::LanguageOf Languages
            ...
        ) ],
        ...
    );

=head1 SUBROUTINES/METHODS

=head2 method languages

E.g. if exists no lexicon for "de-de" but one for "de"
the language is set to "de";

    $loc->languages([ qw( de-de de en ) ]);

And read back what languages are set.

    $languages_ref = $loc->languages;

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Locale::TextDomain::OO::Singleton::Lexicon|Locale::TextDomain::OO::Singleton::Lexicon>

L<Moo::Role|Moo::Role>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

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

Copyright (c) 2013,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
