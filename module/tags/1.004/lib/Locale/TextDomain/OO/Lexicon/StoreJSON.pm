package Locale::TextDomain::OO::Lexicon::StoreJSON; ## no critic (TidyCode)

use strict;
use warnings;
use JSON qw(encode_json);
use Moo;
use MooX::StrictConstructor;
use namespace::autoclean;

our $VERSION = '1.000';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::StoreFile
    Locale::TextDomain::OO::Lexicon::Role::StoreFilter
);

sub to_json {
    my $self = shift;

    return $self->store_content(
        encode_json(
            $self->data({
                msg_key_separator => '{MSG_KEY_SEPARATOR}',
            }),
        ),
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::StoreJSON - Stores the lexicon for other programming languages

$Id$

$HeadURL$

=head1 VERSION

1.000

=head1 DESCRIPTION

This module stores the lexicon for other programming language e.g. JavaScript.

=head1 SYNOPSIS

=head2 write file by given filename

    use Locale::TextDomain::OO::Lexicon::StoreJSON;

    Locale::TextDomain::OO::Lexicon::StoreJSON
        ->new(
            filename => 'my_json_file',
            ...
        )
        ->to_json;

=head2 write file by given open file_handle

    use Carp qw(confess);
    use IO::File;
    use Locale::TextDomain::OO::Lexicon::StoreJSON;

    my $filename = 'my_json_file';
    my $file_handle = IO::File->new( $filename, q{>} )
        or confess qq{Unable to open file "$filename" $!};
    Locale::TextDomain::OO::Lexicon::StoreJSON
        ->new(
            filename    => $filename, # optional for error message only
            file_handle => file_handle,
            ...
        )
        ->to_json;
    $file_handle->close
        or confess qq{Unable to close file "$filename" $!};

=head2 as string

    use Locale::TextDomain::OO::Lexicon::StoreJSON;

    my $json = Locale::TextDomain::OO::Lexicon::StoreJSON
        ->new(
            ...
        )
        ->to_json;

=head2 optional filter

    use Locale::TextDomain::OO::Lexicon::StoreJSON;

    my $json = Locale::TextDomain::OO::Lexicon::StoreJSON
        ->new(
            ...
            # all parameters optional
            filter_domain          => [
                # this domains and unchecked category
                qw( domain1 domain2 ),
            ],
            filter_category        => [
                # this categories and unchecked domain
                qw( category1 category2 ),
            ],
            filter_domain_category => [
                {
                    # empty domain
                    # empty category
                },
                {
                    domain => 'domain3',
                    # empty category
                },
                {
                    # empty domain
                    category => 'category3',
                },
                {
                    domain   => 'domain4',
                    category => 'category4',
                },
            },
        )
        ->to_json;

=head1 SUBROUTINES/METHODS

=head2 method to_json

With file parameters it prints a JSON file.
Otherwise returns a JSON string.

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<JSON|JSON>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Lexicon::Role::StoreFile|Locale::TextDomain::OO::Lexicon::Role::StoreFile>

L<Locale::TextDomain::OO::Lexicon::Role::StoreFilter|Locale::TextDomain::OO::Lexicon::Role::StoreFilter>

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
