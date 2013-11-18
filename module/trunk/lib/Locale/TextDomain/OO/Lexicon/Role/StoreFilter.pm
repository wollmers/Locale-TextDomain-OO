package Locale::TextDomain::OO::Lexicon::Role::StoreFilter; ## no critic (TidyCode)

use strict;
use warnings;
use List::MoreUtils qw(any);
use Locale::TextDomain::OO::Singleton::Lexicon;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(ArrayRef);
use namespace::autoclean;

our $VERSION = '1.000';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
);

has filter_domain => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_category => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_domain_category => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has _domain_category_regex => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $separator = $self->lexicon_key_separator;
        my $not_separator = sprintf '[^%s]', quotemeta $separator;
        return [
            (
                map {
                    qr{
                        \A
                        $not_separator*
                        \Q$separator\E
                        $not_separator*
                        \Q$separator\E
                        \Q$_\E
                        \z
                    }xms;
                } @{ $self->filter_domain }
            ),
            (
                map {
                    qr{
                        \A
                        $not_separator*
                        \Q$separator\E
                        \Q$_\E
                        \Q$separator\E
                        $not_separator*
                        \z
                    }xms;
                } @{ $self->filter_category }
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $category_domain = join
                        $separator,
                        $_->{category} || q{},
                        $_->{domain} || q{};
                    qr{
                        \A
                        $not_separator*
                        \Q$separator\E
                        \Q$category_domain\E
                        \z
                    }xms;
                } @{ $self->filter_domain_category }
            ),
        ],
    },
);

sub data {
    my $self = shift;

    my $data  = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;
    my $regex = $self->_domain_category_regex;
    $data = {
        map { ## no critic (ComplexMappings)
            my $value = { %{ $data->{$_} } };
            delete $value->{ $self->msg_key_separator }->{plural_code};
            $_ => $value;
        }
        grep {
            my $key = $_;
            @{$regex}
                ? any { $key =~ $_ } @{$regex}
                : 1;
        }
        keys %{$data}
    };

    return $data;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::Role::StoreFilter - Filters the lexicon data before stored

$Id$

$HeadURL$

=head1 VERSION

1.000

=head1 DESCRIPTION

This module filters the lexicon date before stored.

The idea is: Not all parts of lexicon are used by other languages.

Implements attributes "filter_domain", "filter_category"
and "filter_domain_category".

That filter removes also the key "plural_code" from header.
That is an already prepared Perl code reference
to calculate what plural form should used.
The other language has to create the code again from key header key "plural".
That contains that pseudo code from po/mo file
without C<;> and/or C<\n> at the end.

=head1 SYNOPSIS

    with qw(
        Locale::TextDomain::OO::Lexicon::Role::StoreFilter
    );

Usage of that optional filter

    use Locale::TextDomain::OO::Lexicon::Store...;

    my $json = Locale::TextDomain::OO::Lexicon::Store...
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
        ->to_...;

=head1 SUBROUTINES/METHODS

=head2 method data

Get back that filtered lexicon data.

    $data = $self->data;

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<List::MoreUtils|List::MoreUtils>

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
