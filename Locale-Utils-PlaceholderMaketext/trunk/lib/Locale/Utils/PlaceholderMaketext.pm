package Locale::Utils::PlaceholderMaketext;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;
use syntax qw(method);

use Scalar::Util qw(looks_like_number);

our $VERSION = '0.001';

has strict => (
    is     => 'rw',
    isa    => 'Bool',
);

has formatter_code => (
    is      => 'rw',
    isa     => 'CodeRef',
    clearer => 'clear_formatter_code',
);

method maketext_to_gettext ($string) {
    defined $string
        or return $string;
    $string =~ s{ ## no critic (ComplexRegexes, EscapedMetacharacter, EnumeratedClasses)
        \[
        (?:
            ( [A-Za-z*\#] [A-Za-z_]* ) # $1 - function name
            ,
            _ ( [1-9]\d* )             # $2 - variable
            ( [^\]]* )                 # $3 - arguments
            |                          # or
            _ ( [1-9]\d* )             # $4 - variable
        )
        \]
    }
    {
        $4 ? "%$4" : "%$1(%$2$3)"
    }xmsge;

    return $string;
};

method gettext_to_maketext ($string) {
    defined $string
        or return $string;
    $string =~ s{ ## no critic (ComplexRegexes, EscapedMetacharacter, EnumeratedClasses)
        %
        (?:
            ( [A-Za-z*\#] [A-Za-z_]* ) # $1 - function name
            [(]
            % ( [1-9]\d* )             # $2 - variable
            ( [^\)]* )                 # $3 - arguments
            [)]
            |                          # or
            ( [1-9]\d* )               # $4 - variable
        )
    }
    {
        $4 ? "[_$4]" : "[$1,_$2$3]"
    }xmsge;

    return $string;
};

# Expand the placeholders

method _replace ($arg_ref, $text, $index_quant, $singular, $plural, $zero, $index_string) {
    if (defined $2) { # quant
        my $number = $arg_ref->[$index_quant - 1];
        if ( ! looks_like_number($number) ) {
            $number = $self->strict ? return $text : 0;
        }
        my $formatted
            = $self->formatter_code
            ? $self->formatter_code->($number, 'numeric', 'quant')
            : $number;
        return
            +( defined $zero && $number == 0 )
            ? $zero
            : $number == 1
            ? (
                defined $singular
                ? "$formatted $singular"
                : return $text
            )
            : (
                defined $plural
                ? "$formatted $plural"
                : defined $singular
                ? "$formatted $singular"
                : return $text
            );
    }
    # replace only
    my $string = $arg_ref->[$index_string - 1];
    defined $string
        or return $self->strict ? $text : q{};

    return
        $self->formatter_code
        ? $self->formatter_code->(
            $string,
            looks_like_number($string) ? 'numeric' : 'string',
        )
        : $string;
};

method expand_maketext ($text, @args) {
    defined $text
        or return $text;

    $text =~ s{ ## no critic (ComplexRegexes)
        (                              # $1: text
            \[ (?:
                (?: quant | [*] )
                , _ ( \d+ )            # $2: n
                , ( [^,\]]* )          # $3: singular
                (?: , ( [^,\]]* ) )?   # $4: plural
                (?: , ( [^,\]]* ) )?   # $5: zero
                |
                _ ( \d+ )              # $6: n
            ) \]
        )
    }
    {
        $self->_replace(\@args, $1, $2, $3, $4, $5, $6)
    }xmsge;

    return $text;
}

method expand_gettext ($text, @args) {
    defined $text
        or return $text;

    $text =~ s{ ## no critic (ComplexRegexes)
        (                           # $1: text
            % (?: quant | [*] )
            [(]
            % ( \d+ )               # $2: n
            , ( [^,\)]* )           # $3: singular
            (?: , ( [^,\)]* ) )?    # $4: plural
            (?: , ( [^,\)]* ) )?    # $5: zero
            [)]
            |
            % ( \d+ )               # $6: n
        )
    }
    {
        $self->_replace(\@args, $1, $2, $3, $4, $5, $6)
    }xmsge;

    return $text;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::Utils::PlaceholderMaketext - Utils to expand maketext palaceholders

$Id:$

$HeadURL:$

=head1 VERSION

0.001

=head1 SYNOPSIS

    use Locale::Utils::PlaceholderMaketext;

    my $obj = Locale::Utils::PlaceholderMaketext->new(
        # optional strict switch
        strict         => 1,
        # optional fromatter code
        formatter_code = sub { ... },
    );

    $expanded = $obj->expand_maketext($text, @args);

=head1 DESCRIPTION

Utils to transform text from maketext to gettext style and reverse.
Utils to expand placeholders in maketext or gettext style.

Locale::Maketext encapsulates the expander.
To use the expander in other modules it is not possible.
Use this module instead.

=head1 SUBROUTINES/METHODS

=head2 method maketext_to_gettext

Maps maketext strings with

 [_1]
 [quant,_2,singular]
 [quant,_3,singular,plural]
 [quant,_4,singular,plural,zero]
 [*,_5,singular]
 [*,_6,singular,plural]
 [*,_7,singular,plural,zero]

inside to

 %1
 %quant(%2,singluar)
 %quant(%3,singluar,plural)
 %quant(%4,singluar,plural,zero)
 %*(%5,singluar)
 %*(%6,singluar,plural)
 %*(%7,singluar,plural,zero)

inside.

    $gettext_string = $obj->maketext_to_gettext($maketext_string);

This method can called as class method too.

    $gettext_string
        = Locale::Utils::PlaceholderMaketext->maketext_to_gettext($maketext_string);

=head2 method gettext_to_maketext

It is the same like method maktetext_to_gettext only the other direction.

    $maketext_string = $obj->gettext_to_maketext($gettext_string);

This method can called as class method too.

    $maketext_string
        = Locale::Utils::PlaceholderMaketext->gettext_to_maketext($gettext_string);

=head2 method strict

If strict is true:
For normal replacement undef will be converted to q{}.
For quant undef will be converted to 0.

    $obj->strict(1); # boolean true or false;

=head2 method formatter_code, clear_formatter_code

If it is needed to localize e.g. the numerics
than describe this in a code reference.

    my $coderef = sub {
        my ($value, $type, $function_name) = @_;

        # $value is never undefined
        # $type is 'numeric' or 'string'
        # $function_name is 'quant' or undef
        ...

        return $value;
    };
    $obj->formatter_code($code_ref);

Than method expand_maketext and expand_gettext
will run this code before the substitution of placeholders.

To switch off this code - clear them.

    $obj->clear_formatter_code;

=head2 method expand_maketext

Expands strings containing maketext placeholders.

maketext style:

 [_1]
 [quant,_1,singular]
 [quant,_1,singular,plural]
 [quant,_1,singular,plural,zero]
 [*,_1,singular]
 [*,_1,singular,plural]
 [*,_1,singular,plural,zero]

    $expanded = $obj->expand_maketext($maketext_text, @args);

=head2 method expand_gettext

Expands strings containing gettext placeholders.

gettext style:

 %1
 %quant(%1,singular)
 %quant(%1,singular,plural)
 %quant(%1,singular,plural,zero)
 %*(%1,singular)
 %*(%1,singular,plural)
 %*(%1,singular,plural,zero)

    $expanded = $obj->expand_maketext($gettext_text, @args);

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

L<Scalar::Util|Scalar::Util>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<Locale::Maketext|Locale::Maketext>

L<http://en.wikipedia.org/wiki/Gettext>

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
