package Locale::Messages::AnyObject;

use strict;
use warnings;

use version; our $VERSION = qv('0.01');

use Carp qw(croak);
use Perl6::Export::Attrs;

our %object_of; ## no critic (PackageVars)

sub set_object :Export(:DEFAULT) {
    my ($text_domain, $object) = @_;

    defined $text_domain
        or croak 'Text domain is undefined';
    length $text_domain
        or croak 'Text domain is empty';

    return $object_of{$text_domain} = $object;
}

sub get_object :Export() {
    my $text_domain = shift;

    defined $text_domain
        or croak 'Text domain is undefined';
    length $text_domain
        or croak 'Text domain is empty';

    exists $object_of{$text_domain}
        or croak
            'Unknown text domain, call set_object'
            . ' to connect the text domain and the object';

    return $object_of{$text_domain};
}

sub dgettext :Export() {
    my ($text_domain, $msgid) = @_;

    return get_object($text_domain)->dgettext(
        $text_domain,
        $msgid,
    );
}

sub dngettext :Export() {
    my ($text_domain, $msgid, $msgid_plural, $count) = @_;

    return get_object($text_domain)->dngettext(
        $text_domain,
        $msgid,
        $msgid_plural,
        $count,
    );
}

sub dpgettext :Export() {
    my ($text_domain, $msgctxt, $msgid) = @_;

    return get_object($text_domain)->dpgettext(
        $text_domain,
        $msgctxt,
        $msgid,
    );
}

sub dnpgettext :Export() {
    my ($text_domain, $msgctxt, $msgid, $msgid_plural, $count) = @_;

    return get_object($text_domain)->dnpgettext(
        $text_domain,
        $msgctxt,
        $msgid,
        $msgid_plural,
        $count,
    );
}

1;

__END__

=head1 NAME

Locale::Messages::AnyObject - Perl Interface to use gettext but not mo-files

$Id: AnyObject.pm 16 2009-08-28 13:55:35Z steffenw $

$HeadURL: https://catatylstgettex.svn.sourceforge.net/svnroot/catatylstgettex/Locale-Text-Domain-OO/trunk/lib/Locale/Messages/AnyObject.pm $

=head1 VERSION

0.01

=head1 DESCRIPTION

This module maps the subroutine call for
dgettext, dngettext, dpgettext and dnpgettext
back to object method calls with the same name.

So the module L<Locale::Text::Domain::OO>
can accept this module instead of module L<Locale::Messages>.

This module allows to connect your own object-oriented modules
if your message catalog is not an mo-file.

L<Locale::Messages::Struct> ist such one.
The idea is to read the database information into a data structure
for fast access.

=head1 SYNOPSIS

    use Locale::Messages::AnyObject;

=head1 SUBROUTINES/METHODS

=head2 sub set_object

This sub is exported by default.

    set_object($text_domain, $object);

=head2 sub get_object

    $object = set_object($text_domain);

=head2 sub dgettext

    $translation = dgettext($text_domain, $msgid);

=head2 sub dngettext

    $translation = dngettext($text_domain, $msgid, $msgid_plural, $count);

=head2 sub dpgettext

    $translation = dpgettext($text_domain, $msgctxt, $msgid);

=head2 sub dnpgettext

    $translation = dnpgettext($text_domain, $msgctxt, $msgid, $msgid_plural, $count);

=head1 EXAMPLE

Inside of this Distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

A text domain is a non empty string.

 Text domain is undefined

 Text doamin is empty

Method get_object could not find the object.

 Unknown text domain, call set_object to connect the text domain and the object

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Perl6::Export::Attrs>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO>

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