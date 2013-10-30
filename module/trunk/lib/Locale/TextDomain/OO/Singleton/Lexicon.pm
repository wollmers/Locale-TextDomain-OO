package Locale::TextDomain::OO::Singleton::Lexicon; ## no critic (TidyCode)

use strict;
use warnings;
use Moo;
use MooX::StrictConstructor;
use namespace::autoclean;

our $VERSION = '1.000';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
    MooX::Singleton
);

has data => (
    is       => 'ro',
    init_arg => undef,
    default  => sub {
        my $self = shift;    
        return {
            # empty lexicon of developer English
            'i-default::' => {
                $self->msg_key_separator => {
                    nplurals    => 2,
                    plural_code => sub { return shift != 1 },
                },
            },
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Singleton::Lexicon - Provides singleton lexicon access

$Id$

$HeadURL$

=head1 VERSION

1.000

=head1 DESCRIPTION

This module provides the singleton lexicon access
for L<Locale::TextDomain:OO|Locale::TextDomain:OO>.

=head1 SYNOPSIS

    Locale::TextDomain::OO::Singleton::Lexicon;

    $lexicon_data = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;

=head1 SUBROUTINES/METHODS

=head2 method data

Get back the lexicon hash reference
to fill the lexicon or to read from lexicon.

    $lexicon_data = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<namespace::autoclean|namespace::autoclean>

L<MooX::Singleton|MooX::Singleton>

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
