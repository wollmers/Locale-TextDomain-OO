package Locale::Utils::PlaceholderNamed; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use Moo;
use MooX::StrictConstructor;
use MooX::Types::MooseLike::Base qw(Bool);
use namespace::autoclean;

our $VERSION = '0.004';

has strict => (
    is  => 'rw',
    isa => Bool,
);

sub _mangle_value {
    my ($self, $placeholder, $value) = @_;

    return
        defined $value
        ? $value
        : $self->strict
        ? $placeholder
        : q{};
}

sub expand_named {
    my ($self, $text, @args) = @_;

    defined $text
        or return $text;
    my $arg_ref = @args == 1
        ? $args[0]
        : {
            @args % 2
            ? confess 'Arguments expected pairwise'
            : @args
        };

    my $regex = join q{|}, map { quotemeta $_ } keys %{$arg_ref};
    $text =~ s{ ## no critic (ComplexRegexes)
        ( [{] ( $regex ) [}] )
    }
    {
        $self->_mangle_value($1, $arg_ref->{$2})
    }xmsge;

    return $text;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::Utils::PlaceholderNamed - Utils to expand named placeholders

$Id$

$HeadURL$

=head1 VERSION

0.004

=head1 SYNOPSIS

    use Locale::Utils::PlaceholderNamed;

    my $obj = Locale::Utils::PlaceholderNamed->new(
        # optional strict switch
        strict => 1,
    );

    $expanded = $obj->expand_named($text, %args);
    $expanded = $obj->expand_named($text, \%args);

=head1 DESCRIPTION

Utils to expand named placeholders.

=head1 SUBROUTINES/METHODS

=head2 method strict

If strict is false: undef will be converted to q{}.
If strict is true: no replacement.

    $obj->strict(1); # boolean true or false;

=head2 method expand_named

Expands strings containing named placeholders like C<{name}>.

    $text = 'foo {name} baz';
    %args = (
        name => 'bar',
    );

    $expanded = $obj->expand_named($text, %args);

or

    $expanded = $obj->expand_text($text, \%args);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run the *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<MooX::Types::MooseLike|MooX::Types::MooseLike>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Gettext>

L<Locale::TextDomain|Locale::TextDomain>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 - 2013,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
