package Locale::TextDomain::OO::Lexicon::Role::File; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use Encode qw(decode FB_CROAK);
use English qw(-no_match_vars $OS_ERROR);
use Locale::TextDomain::OO::Singleton::Lexicon;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(CodeRef);
use Path::Tiny qw(path);
use namespace::autoclean;

our $VERSION = '1.006';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::ExtractHeader
    Locale::TextDomain::OO::Lexicon::Role::GettextToMaketext
    Locale::TextDomain::OO::Role::Logger
);

requires qw(
    read_messages
);

has decode_code => (
    is      => 'ro',
    isa     => CodeRef,
    lazy    => 1,
    default => sub {
        sub {
            my ($charset, $text) = @_;
            defined $text
                or return $text;

            return decode( $charset, $text, FB_CROAK );
        };
    },
);

sub _decode_messages {
    my ($self, $messages) = @_;

    my $charset = lc $messages->[0]->{charset};
    for my $value ( @{$messages} ) {
        for my $key ( qw( msgid msgid_plural msgstr ) ) {
            if ( exists $value->{$key} ) {
                for my $text ( $value->{$key} ) {
                    $text = $self->decode_code->($charset, $text);
                }
            }
        }
        if ( exists $value->{msgstr_plural} ) {
            my $got      = @{ $value->{msgstr_plural} };
            my $expected = $messages->[0]->{nplurals};
            $got == $expected or confess sprintf
                'Count of msgstr_plural=%s but nplurals=%s for msgid="%s" msgid_plural="%s"',
                $got,
                $expected,
                ( exists $value->{msgid}        ? $value->{msgid}        : q{} ),
                ( exists $value->{msgid_plural} ? $value->{msgid_plural} : q{} );
            for my $text ( @{ $value->{msgstr_plural} } ) {
                $text = $self->decode_code->($charset, $text);
            }
        }
    }

    return;
}

sub _my_glob {
    my ($self, $file) = @_;

    my $dirname  = $file->dirname;
    my $filename = $file->basename;

    # only one * allowed at all
    my $dir_star_count  = () = $dirname  =~ m{ [*] }xmsg;
    my $file_star_count = () = $filename =~ m{ [*] }xmsg;
    my $count = $dir_star_count + $file_star_count;
    $count
        or return $file;
    $count > 1
        and confess 'Only one * in dirname/filename is allowd to reference the language';

    # one * in filename
    if ( $file_star_count ) {
        ( my $file_regex = quotemeta $filename ) =~ s{\\[*]}{.*?}xms;
        return path($dirname)->childreen( qr{$file_regex}xms );
    }

    # one * in dir
    # split that dir into left, inner with * and right
    my ( $left_dir, $inner_dir, $right_dir )
        = split qr{( [^/*]* [*] [^/]* )}xms, $dirname;
    ( my $inner_dir_regex = quotemeta $inner_dir ) =~ s{\\[*]}{.*?}xms;
    my @left_and_inner_dirs
        = path($left_dir)->children( qr{\A $inner_dir_regex \z}xms );

    return
        grep {
            $_->is_file;
        }
        map {
            path($_, $right_dir, $filename);
        } @left_and_inner_dirs;
}

sub lexicon_ref {
    my ($self, $file_lexicon) = @_;

    my $lexicon = Locale::TextDomain::OO::Singleton::Lexicon->instance;
    my $search_dirs = $file_lexicon->{search_dirs}
        or confess 'Hash key "search_dirs" expected';
    my $data = $file_lexicon->{data};
    for my $dir ( @{ $search_dirs } ) {
        my $index = 0;
        while ( $index < @{ $file_lexicon->{data} } ) {
            my ($lexicon_key, $lexicon_value)
                = ( $data->[ $index++ ], $data->[ $index++ ] );
            my $file = path( $dir, $lexicon_value );
            my @files = $self->_my_glob($file);
            for ( @files ) {
                my $filename = $_->canonpath;
                my $lexicon_language_key = $lexicon_key;
                my $language = $filename;
                my @parts = split m{[*]}xms, $file;
                if ( @parts == 2 ) {
                    substr $language, 0, length $parts[0], q{};
                    substr $language, - length $parts[1], length $parts[1], q{};
                    $lexicon_language_key =~ s{[*]}{$language}xms;
                }
                my $messages = $self->read_messages($filename);
                my $header_msgstr = $messages->[0]->{msgstr}
                    or confess 'msgstr of header not found';
                my $header = $messages->[0];
                %{$header} = (
                    msgid => $header->{msgid},
                    %{ $self->extract_header_msgstr( $header->{msgstr} ) },
                );
                $file_lexicon->{gettext_to_maketext}
                    and $self->gettext_to_maketext($messages);
                $file_lexicon->{decode}
                    and $self->_decode_messages($messages);
                $messages = $self->message_array_to_hash($messages);
                $lexicon->data->{$lexicon_language_key} = $messages;
                $self->logger
                    and $self->logger->(
                        qq{Lexicon "$lexicon_language_key" loaded from file "$filename".},
                        {
                            object => $self,
                            type   => 'debug',
                            event  => 'lexicon,load',
                        },
                    );
            }
        }
    }

    return $self;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::Role::File - Helper role to add lexicon from file

$Id$

$HeadURL$

=head1 VERSION

1.006

=head1 DESCRIPTION

This module provides methods to inplmement lexicon from file easy.

=head1 SYNOPSIS

    with qw(
        Locale::TextDomain::OO::Lexicon::Role::File
    );

=head1 SUBROUTINES/METHODS

=head2 attribute decode_code

Allows to implement your own way of decode messages.
Add a code ref in constructor.

    decode_code => sub {
        my ($charset, $text) = @_;
        defined $text
            or return $text;

        return decode( $charset, $text );
    },

=head2 method lexicon_ref

    $self->lexicon_ref({
        # required
        search_dirs => [ qw( ./my_dir ./my_other_dir ) ],
        # optional
        gettext_to_maketext => $boolean,
        # optional
        decode => $boolean,
        # required
        data => [
            # e.g. de.mo, en.mo read from:
            # search_dir/de.mo
            # search_dir/en.mo
            '*::' => '*.mo',
            # e.g. de.mo en.mo read from:
            # search_dir/subdir/de/LC_MESSAGES/domain.mo
            # search_dir/subdir/en/LC_MESSAGES/domain.mo
            '*:LC_MESSAGES:domain' => 'subdir/*/LC_MESSAGES/domain.mo',
        ],
    });

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<Encode|Encode>

L<English|English>

L<Locale::TextDomain::OO::Singleton::Lexicon|Locale::TextDomain::OO::Singleton::Lexicon>

L<Moo::Role|Moo::Role>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<Path::Tiny|Path::Tiny>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Lexicon::Role::ExtractHeader|Locale::TextDomain::OO::Lexicon::Role::ExtractHeader>

L<Locale::TextDomain::OO::Lexicon::Role::GettextToMaketext|Locale::TextDomain::OO::Lexicon::Role::GettextToMaketext>

L<Locale::TextDomain::OO::Role::Logger|Locale::TextDomain::OO::Role::Logger>

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
