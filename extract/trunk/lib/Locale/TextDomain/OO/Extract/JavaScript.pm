package Locale::TextDomain::OO::Extract::JavaScript;

use strict;
use warnings;

use version; our $VERSION = qv('0.05');

use parent qw(Locale::TextDomain::OO::Extract);

my $domain_rule
    = my $context_rule
    = my $text_rule
    = my $singular_rule
    = my $plural_rule
    = [
        [
            qr{"}xms,
            qr{( (?: \\\\ \\\\ | \\\\ " | [^"] )+ )}xms,
            qr{"}xms,
        ],
        'OR',
        [
            qr{'}xms,
            qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
            qr{'}xms,
        ],
    ];

my $komma_rule = qr{\s* , \s*}xms;

my $start_rule = qr{(?: _ | d? c? n? p? gettext ) \s* \(}xms;

my $rules = [
    [
        [
            [ qr{_ () \s* \( \s*}xms ],
            'OR',
            [ qr{\b (c?) gettext \( \s*}xms ],
        ],
        $text_rule,
    ],
    'OR',
    [
        qr{\b (d c?) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{\b (c? n) gettext \s* \( \s*}xms,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{\b (d c? n) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{\b (c? p) gettext \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{\b (d c? p) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{\b (c? n p) gettext \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{\b (d c? n p) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $context_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
];

# remove comment code
sub preprocess {
    my $self = shift;

    my $content_ref = $self->get_content_ref();

    ${$content_ref} =~ s{// [^\n]* $}{}xmsg;
    ${$content_ref} =~ s{
        / \* (.*?) \* /
    }{
        join q{}, $1 =~ m{(\n)}xmsg;
    }xmsge;

    return $self;
}

my %char_of = (
    b => "\b",
    f => "\f",
    n => "\n",
    r => "\r",
    t => "\t",
);

sub _interpolate_escape_sequence {
    my ($self, $string) = @_;

    # nothing to interpolate
    defined $string
        or return;

    $string =~ s{
        \\
        (?:
            ( [bfnrt] ) # Backspace
                        # Form feed
                        # New line
                        # Carriage return
                        # Horizontal tab
            | u ( [0-9A-Fa-f]{4} ) # Unicode sequence (4 hex digits: dddd)
            | x ( [0-9A-Fa-f]{2} ) # Hexadecimal sequence (2 digits: dd)
            |   ( [0-3][0-7]{2}  ) # Octal sequence (3 digits: ddd)
            | (.) # Backslash itself
                  # Single quotation mark
                  # Double quotation mark
                  # anything else that needs no escape
        )
    }{
       $1 ? $char_of{$1} :
       $2 ? chr hex $2   :
       $3 ? chr hex $3   :
       $4 ? chr oct $4   :
       $5
    }xmsge;

    return $string;
}

sub stack_item_mapping {
    my ($self, $stack_item) = @_;

    my $extra_parameter = shift @{$stack_item};
    if ( $extra_parameter =~ m{d}xms) {
         shift @{$stack_item};
    }
    @{$stack_item}
        or return;

    return {
        msgctxt      => $extra_parameter =~ m{p}xms
                        ? scalar $self->_interpolate_escape_sequence(
                            shift @{$stack_item}
                        )
                        : undef,
        msgid        => scalar $self->_interpolate_escape_sequence(
                            shift @{$stack_item}
                        ),
        msgid_plural => scalar $self->_interpolate_escape_sequence(
                            shift @{$stack_item}
                        ),

    };
}

sub new {
    my ($class, %init) = @_;

    return $class->SUPER::new(
        start_rule => $start_rule,
        rules      => $rules,
        %init,
    );
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Extract::JavaScript
- Extracts internationalization data from JavaScript code

$Id: JavaScript.pm 271 2010-01-16 07:37:06Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract/JavaScript.pm $

=head1 VERSION

0.04

=head1 DESCRIPTION

This module extracts internationalization data from JavaScript code.

Implemented Rules:

 _('...
 gettext('...
 cgettext('...

 dgettext('...
 dcgettext('...

 ngettext('...
 cngettext('...

 dngettext('...
 dcngettext('...

 pgettext('...
 cpgettext('...

 dpgettext('...
 dcpgettext('...

 npgettext('...
 cnpgettext('...

 dnpgettext('...
 dcnpgettext('...

Alternative quoting with " is allowed.
Whitespace is allowed everywhere.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::JavaScript;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.
See Locale::TextDomain::OO::Extract to replace the defaults.

    my $extractor = Locale::TextDomain::OO::Extract::JavaScript->new(
        # where to store the pot file
        pot_dir => './',

        # how to store the pot file
        # - The meaning of undef is ISO-8859-1 but use not Perl unicode.
        # - Set 'ISO-8859-1' to have a ISO-8859-1 pot file and use Perl unicode.
        # - Set 'UTF-8' to have a UTF-8 pot file and use Perl unicode.
        # And so on.
        pot_charset => undef,

        # add some key value pairs to the header
        # more see documentation of DBD::PO
        pot_header => { ... },
    );

=head2 method extract

The default pot_dir is "./".

Call

    $extractor->extract('dir/filename.js');

to extract "dir/filename.js" to have a "$pot_dir/dir/filename.js.pot".

Call

    open my $file_handle, '<', 'dir/filename.js'
        or croak "Can no open file dir/filename.js\n$OS_ERROR";
    $extractor->extract('filename', $file_handle);

to extract "dir/filename.js" to have a "$pot_dir/filename.pot".

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

see Locale::TextDomain::OO::Extract

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

version

parent

L<Locale::TextDomain::OO::Extract>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO>

L<http://jsgettext.berlios.de/>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 - 2010,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut