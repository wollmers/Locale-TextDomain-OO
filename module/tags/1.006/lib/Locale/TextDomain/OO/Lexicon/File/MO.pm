package Locale::TextDomain::OO::Lexicon::File::MO; ## no critic (TidyCode)

use strict;
use warnings;
require Locale::MO::File;
use Moo;
use MooX::StrictConstructor;
use namespace::autoclean;

our $VERSION = '1.006';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::File
);

sub read_messages {
    my ($self, $filename) = @_;

    return Locale::MO::File
        ->new( filename => $filename )
        ->read_file
        ->get_messages;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::File::MO - Gettext mo file as lexicon

$Id$

$HeadURL$

=head1 VERSION

1.006

=head1 DESCRIPTION

This module reads a gettext mo file into the lexicon.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Lexicon::File::MO;

    Locale::TextDomain::OO::Lexicon::File::MO
        ->new(
            # all parameters are optional
            decode_code => sub {
                my ($charset, $text) = @_;
                defined $text
                    or return $text;
                return decode( $charset, $text );
            },
            # optional
            logger => sub {
                my ($message, $arg_ref) = @_;
                my $type = $arg_ref->{type}; # debug
                Log::Log4perl->get_logger(...)->$type($message);
                return;
            },
        )
        ->lexicon_ref({
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

=head1 SUBROUTINES/METHODS

=head2 method lexicon_ref

See SYNOPSIS.

=head2 method read_messages

Called from Locale::TextDomain::OO::Lexicon::Role::File
to run the mo file specific code.

    $messages_ref = $self->read_messages($filename);

=head2 method logger

Set the logger

    $lexicon_file_mo->logger(
        sub {
            my ($message, $arg_ref) = @_;
            my $type = $arg_ref->{type};
            Log::Log4perl->get_logger(...)->$type($message);
            return;
        },
    );

$arg_ref contains

    object => $lexicon_file_mo, # the object itself
    type   => 'debug',
    event  => 'lexicon,load',

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Locale::MO::File|Locale::MO::File>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<Locale::TextDomain::OO::Lexicon::Role::File|Locale::TextDomain::OO::Lexicon::Role::File>

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
