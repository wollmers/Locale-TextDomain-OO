package Locale::Utils::PluralForms;

use Moose;
use MooseX::StrictConstructor;

use namespace::autoclean;
use syntax qw(method);

use English qw(-no_match_vars $EVAL_ERROR);
use HTML::Entities qw(decode_entities);
require LWP::UserAgent;
require Safe;

our $VERSION = '0.001';

has language => (
    is       => 'rw',
    isa      => 'Str',
    trigger  => \&_language,
);

has _all_plural_forms_url => (
    is       => 'rw',
    isa      => 'Str',
    default  => 'http://translate.sourceforge.net/wiki/l10n/pluralforms',
);

has _all_plural_forms_html => (
    is       => 'rw',
    isa      => 'Str',
    default  => \&_get_all_plural_forms_html,
    lazy     => 1,
    clearer  => 'clear_all_plural_forms_html',
);

has all_plural_forms => (
    is       => 'rw',
    isa      => 'HashRef',
    default  => \&_get_all_plural_forms,
    lazy     => 1,
);

has plural_forms => (
    is      => 'rw',
    isa     => 'Str',
    default => 'nplurals=1; plural=0',
    lazy    => 1,
    trigger => \&_calculate_plural_forms,
);

has nplurals => (
    is       => 'rw',
    isa      => 'Int',
    default  => 1,
    lazy     => 1,
    init_arg => undef,
    writer   => '_nplurals',
);

has plural_code => (
    is       => 'rw',
    isa      => 'CodeRef',
    default  => sub { return sub { return 0 } },
    lazy     => 1,
    init_arg => undef,
    writer   => '_plural_code',
);

has strict => (
    is      => 'rw',
    isa     => 'Bool',
    clearer => 'clear_strict',
);

method _get_all_plural_forms_html () {
    my $url = $self->_all_plural_forms_url;
    my $ua  = LWP::UserAgent->new;
    $ua->env_proxy;
    my $response = $ua->get($url);
    $response->is_success
        or confess "$url $response->status_line";

    return $response->decoded_content;
}

method _get_all_plural_forms () {
    my @match = $self->_all_plural_forms_html =~ m{ # no critic(ComplexRegexes)
        .*?
        <td \s+ class="col0"> \s* ( [^<]+? ) \s* <
        .*?
        <td \s+ class="col1"> \s* ( [^<]+? ) \s* <
        .*?
        <td \s+ class="col2 [^"]* "> \s* ( [^<]+? ) \s* <
    }xmsg;
    $self->clear_all_plural_forms_html;
    my %all_plural_forms;
    while ( my ($iso, $english_name, $plural_forms) = splice @match, 0, 3 ) { ## no critic (MagicNumbers)
        $all_plural_forms{ decode_entities($iso) } = {
            english_name => decode_entities($english_name),
            plural_forms => decode_entities($plural_forms),
        };
    }

    return \%all_plural_forms;
}

method _language ($language) {
    my $all_plural_forms = $self->all_plural_forms;
    if ( exists $all_plural_forms->{$language} ) {
        return $self->plural_forms(
            $all_plural_forms->{$language}->{plural_forms}
        );
    }
    $language =~ s{_ .* \z}{}xms;
    if ( exists $all_plural_forms->{$language} ) {
        return $self->plural_forms(
            $all_plural_forms->{$language}->{plural_forms}
        );
    }

    return confess
        "Missing plural forms for language $language in all_plural_forms";
}

method _calculate_plural_forms () {
    my $plural_forms = $self->plural_forms;
    $plural_forms =~ s{\b ( nplurals | plural | n ) \b}{\$$1}xmsg;
    my $safe = Safe->new;
    {
        my $code = <<"EOC";
            my \$n = 0;
            my (\$nplurals, \$plural);
            $plural_forms;
            \$nplurals;
EOC
        $self->_nplurals(
            $safe->reval($code)
            or confess
                "Code of Plural-Forms $plural_forms is not safe, $EVAL_ERROR"
        );
    }
    {
        my $code = <<"EOC";
            sub {
                my \$n = shift;

                my (\$nplurals, \$plural);
                $plural_forms;

                return \$plural || 0;
            }
EOC
        $self->_plural_code(
            $safe->reval($code)
            or confess "Code $plural_forms is not safe, $EVAL_ERROR"
        );
    }

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::Utils::PluralForms - Utils to use plural forms

$Id:$

$HeadURL:$

=head1 VERSION

0.001

=head1 SYNOPSIS

    use Locale::Utils::PlaceholderNamed;

    $obj = Locale::Utils::PlaceholderNamed->new;

=head1 DESCRIPTION

Utils to calculate the plural forms and expand named placeholders.

The header of a PO file is quite complex.
This module helps to build the header and extract.

In this header, an entry is called "Plural-Forms".
How many plural forms the language has, is described there.
The second Information in "Plural-Forms" describes as a code,
how to choose the correct plural form.

Some phrases contain placeholders.
Here are the methods to replace these.

=head1 SUBROUTINES/METHODS

=head2 Calculate the plural forms

All attributes are optional.
The attribute values are the defaults to show them.

    $obj = Locale::PO::Utils->new(
        plural_forms => 'nplurals=1; plural=0',
    );

The defaults for nplural and plural_code is:

    $obj->nplurals    # returns: 1
    $obj->plural_code # returns: sub { return 0 }

The attribute setter is named plural_forms.
There are no public setter for attributes nplurals and plural_code
and it is not possible to set them in the constructor.
Call method plural_forms or set attribute plural_forms in the constructor.
After that nplurals and plual_code will be calculated automaticly and safe.

The attribute getter are named plural_forms, nplurals and plural_code.

=head2 method plural_forms

Plural forms are defined like this for English:

    $obj->plural_forms('nplurals=2; plural=(n != 1)');

After that this method calculates and set
nplurals and the plural_code safe.

=head2 method nplurals

This method get back the calculated count of plural forms.
The default value before any calculation is C<1>.

    $nplurals = $obj->nplurals;

=head2 method plural_code

This method get back the calculated code for the calculaded plural form
to choose the correct plural.
The default value before any calculation is C<sub {return 0}>.

For the example C<'nplurals=2; plural=(n != 1)'>:

    $plural = $obj->plural_code->(0), # $plural is 1
    $plural = $obj->plural_code->(1), # $plural is 0
    $plural = $obj->plural_code->(2), # $plural is 1
    $plural = $obj->plural_code->(3), # $plural is 1
    ...

=head2 method expand_text

Expands strings containing gettext placeholders like C<{name}>.

    $expanded = $obj->expand_text($text, %args);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run the *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moose|Moose>

L<MooseX::StrictConstructor|MooseX::StrictConstructor>

L<namespace::autoclean|namespace::autoclean>

L<syntax|syntax>

L<English|English>

L<HTML::Entities|HTML::Entities>

L<LWP::UserAgent|LWP::UserAgent>

L<Safe|Safe>

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
