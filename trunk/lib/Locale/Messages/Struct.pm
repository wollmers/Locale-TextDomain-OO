package Locale::Messages::Struct;

use strict;
use warnings;

use version;our $VERSION = qv('0.01');

use Carp qw(croak);

sub new {
    my ($class, $ref) = @_;

    return bless $ref, $class;
}

my $define = sub {
    my ($ref, $key) = @_;

    exists $ref->{$key}
        or return q{};
    my $value = $ref->{$key};
    defined $value
        or return q{};

    return $value;
};

sub _get_text_domain_data {
    my ($self, $text_domain) = @_;

    defined $text_domain
        or croak 'Undefined text domain';
    length $text_domain
        or croak 'Empty text domain';
    my $data_ref = $self->{$text_domain};
    ref $data_ref eq 'HASH'
        or croak "Data of text domain $text_domain missing";

    return $data_ref;
}

sub _get_array_ref {
    my ($self, $text_domain) = @_;

    my $text_doamin_data = $self->_get_text_domain_data($text_domain);
    my $array_ref        = $text_doamin_data->{array_ref};
    ref $array_ref eq 'ARRAY'
        or croak "array_ref data for text domain $text_domain missing";

    return $array_ref;
};

sub _get_plural_ref {
    my ($self, $text_domain) = @_;

    my $text_doamin_data = $self->_get_text_domain_data($text_domain);
    my $plural_ref       = $text_doamin_data->{plural_ref};
    ref $plural_ref eq 'CODE'
        or croak "plural_ref data for text domain $text_domain missing";

    return $plural_ref;
};

sub dgettext {
    my ($self, $text_domain, $msgid) = @_;

    ENTRY:
    for my $entry ( @{ $self->_get_array_ref($text_domain) } ) {
        length $define->($entry, 'msgctxt')
            and next ENTRY;
        $define->($entry, 'msgid') eq $msgid
            and return $define->($entry, 'msgstr');
    }

    return q{};
}

sub dngettext {
    my ($self, $text_domain, $msgid, $msgid_plural, $count) = @_;

    my $msgstr_index = $self->_get_plural_ref($text_domain)->($count);
    ENTRY:
    for my $entry ( @{ $self->_get_array_ref($text_domain) } ) {
        length $define->($entry, 'msgctxt')
            and next ENTRY;
        if ($msgstr_index) {
            $define->($entry, 'msgid_plural') eq $msgid_plural
                and return $define->($entry, "msgstr_$msgstr_index");
        }
        else {
            $define->($entry, 'msgid') eq $msgid
                and return $define->($entry, 'msgstr_0');
        }
    }

    return q{};
}

sub dpgettext {
    my ($self, $text_domain, $msgctxt, $msgid) = @_;

    ENTRY:
    for my $entry ( @{ $self->_get_array_ref($text_domain) } ) {
        $define->($entry, 'msgctxt') eq $msgctxt
            or next ENTRY;
        $define->($entry, 'msgid') eq $msgid
            and return $define->($entry, 'msgstr');
    }

    return q{};
}

sub dnpgettext { ## no critic (ManyArgs)
    my ($self, $text_domain, $msgctxt, $msgid, $msgid_plural, $count) = @_;

    my $msgstr_index = $self->_get_plural_ref($text_domain)->($count);
    ENTRY:
    for my $entry ( @{ $self->_get_array_ref($text_domain) } ) {
        $define->($entry, 'msgctxt') eq $msgctxt
            or next ENTRY;
        if ($msgstr_index) {
            $define->($entry, 'msgid_plural') eq $msgid_plural
                and return $define->($entry, "msgstr_$msgstr_index");
        }
        else {
            $define->($entry, 'msgid') eq $msgid
                and return $define->($entry, 'msgstr_0');
        }
    }

    return q{};
}

1;

__END__

=head1 NAME

Locale::Messages::Struct - Perl Interface extension to use gettext and not mo-files

$Id$

$HeadURL$

=head1 VERSION

0.01

=head1 DESCRIPTION

This module allows the access with gettext methods to a data struct.
Maybe such data were read from a database.

To bind this module to L<Locale::TextDomain::OO>
the module L<Locale::Messages::AnyObject> is necessary
because L<Locale::Messages> and L<Locale::Messages::AnyObject>
have both an fuctional interface.

=head1 SYNOPSIS

    require Locale::Messages::Struct;

=head1 SUBROUTINES/METHODS

=head2 method new

    my $text_domain = 'text_domain';
    my %struct = (
        $text_domain => {
            plural_ref = sub {
                my $n = shift;

                my ($nplurals, $plural);
                # The next line is like Plural-Forms at the po/mo-file.
                $nplurals=2; $plural=$n != 1;

                return $plural;
            },
            array_ref => [
                # as example the keys with an empty value
                msgctxt      => q{},
                msgid        => 'must have a none empty value',
                msgid_plural => q{},
                msgstr       => q{},
                msgstr_0     => q{},
                msgstr_1     => q{},
                msgstr_2     => q{},
                msgstr_3     => q{},
                msgstr_4     => q{},
                msgstr_5     => q{},
            ],
        },
    );
    my $loc = Locale::Messages::Struct->new($text_domain, \%struct);

=head2 method dgettext

    $translation = $loc->dgettext($text_domain, $msgid);

=head2 method dngettext

    $translation = $loc->dngettext($text_domain, $msgid, $msgid_plural, $count);

=head2 method dpgettext

    $translation = $loc->dpgettext($text_domain, $msgctxt, $msgid);

=head2 method dnpgettext

    $translation = dnpgettext($text_domain, $msgctxt, $msgid, $msgid_plural, $count);

=head1 EXAMPLE

Inside of this Distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error at translating methods.

 Undefined text domain

 Empty text domain

 Data of text domain ... missing

 array_ref data for text domain ... missing

 plural_ref data for text domain ... missing

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

Carp

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin:OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut