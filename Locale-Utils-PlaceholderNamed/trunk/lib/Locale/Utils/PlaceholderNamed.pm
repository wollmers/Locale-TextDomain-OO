package Locale::Utils::PlaceholderNamed;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;
use syntax qw(method);

our $VERSION = '0.001';

has strict => (
    is      => 'rw',
    isa     => 'Bool',
);

method _mangle_value ($placeholder, $value) {
    return
        defined $value
        ? $value
        : $self->strict
        ? $placeholder
        : q{};
}

method expand_named ($text, %args) {
    defined $text
        or return $text;

    my $regex = join q{|}, map { quotemeta $_ } keys %args;
    $text =~ s{ ## no critic (ComplexRegexes)
        ( [{] ( $regex ) [}] )
    }
    {
        $self->_mangle_value($1, $args{$2})
    }xmsge;

    return $text;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::Utils::PlaceholderNamed - Utils to expand named placeholders

$Id:$

$HeadURL:$

=head1 VERSION

0.001

=head1 SYNOPSIS

    use Locale::Utils::PlaceholderNamed;

    my $obj = Locale::Utils::PlaceholderNamed->new(
        # optional strict switch
        strict         => 1,
    );

    $expanded = $obj->expand_named($text, %args);

=head1 DESCRIPTION

Utils to expand named placeholders.

=head1 SUBROUTINES/METHODS

=head2 method strict

If strict is true: undef will be converted to q{}.
If strict is false: no replacement.

    $obj->strict(1); # boolean true or false;

=head2 method expand_text

Expands strings containing named placeholders like C<{name}>.

named style:

 {name_is_key_of_args_hash}

    $expanded = $obj->expand_text($text, %args);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run the *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

Moose

L<MooseX::StrictConstructor|MooseX::StrictConstructor>

L<namespace::autoclean|namespace::autoclean>

L<syntax|syntax>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Gettext>

L<http://translate.sourceforge.net/wiki/l10n/pluralforms>

L<Locele::TextDomain|Locele::TextDomain>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
