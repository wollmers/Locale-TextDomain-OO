package Locale::TextDomain::OO::Extract::Perl;

use strict;
use warnings;

use version; our $VERSION = qv('1.00');

use parent qw(Locale::TextDomain::OO::Extract);

my $context_rule
    = my $text_rule
    = my $singular_rule
    = my $plural_rule
    = [
        qr{'}xms,
        qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
        qr{'}xms,
    ];

my $komma_rule = qr{\s* , \s*}xms;

my $start_rule = qr{
    (?:
        __ n?p?x?
        |
        maketext (?: _p )?
    )
    \s*
    \(
}xms;

my $rules = [
    [
        qr{__ (x?) \s* \( \s*}xms,
        $text_rule,
    ],
    'OR',
    [
        qr{__ (nx?) \s* \( \s*}xms,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{__ (px?) \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{__ (npx?) \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{maketext () \s* \( \s*}xms,
        $text_rule,
    ],
    'OR',
    [
        qr{maketext_ (p) \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
];

sub preprocess {
    my $self = shift;

    my $content_ref = $self->get_content_ref();

    my ($is_pod, $is_end);
    ${$content_ref} = join "\n", map {
        $_ eq '__END__'  ? do { $is_end = 1; q{} }
        : $is_end        ? ()
        : m{= (\w+)}xms  ? (
            lc $1 eq 'cut'
            ? do { $is_pod = 0; q{} }
            : do { $is_pod = 1; q{} }
        )
        : $is_pod        ? q{}
        : $_;
    } split m{\r? \n \r?}xms, ${$content_ref};

    return $self;
}

sub stack_item_mapping {
    my ($self, $stack_item) = @_;

    my $match = $stack_item->{match};
    my $extra_parameter = shift @{$match};
    @{$match}
        or return;

    return {
        reference    => "$stack_item->{file_name}:$stack_item->{line_number}",
        msgctxt      => $extra_parameter =~ m{p}xms
                        ? scalar shift @{$match}
                        : undef,
        msgid        => scalar shift @{$match},
        msgid_plural => scalar shift @{$match},
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

Locale::TextDomain::OO::Extract::Perl
- Extracts internationalization data from Perl source code

$Id: Perl.pm 271 2010-01-16 07:37:06Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract/Perl.pm $

=head1 VERSION

0.04

=head1 DESCRIPTION

This module extracts internationalization data from Perl source code.

Implemented rules:

 __('...
 __x('...
 __n('...
 __nx('...
 __p('...
 __px('...
 __np('...
 __npx('...
 maketext('...
 maketext_p('...

Anything before __ is allowed, e.g. N__ and so on.
Whitespace is allowed everywhere.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::Perl;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.
See Locale::TextDomain::OO::Extract to replace the defaults.

    my $extractor = Locale::TextDomain::OO::Extract::Perl->new(
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

        # how to write the pot file
        is_append => $boolean,

        # debug output for other rules than perl
        run_debug => ':all !parser', # debug all but not the parser
                     # :all    - switch on all debugs
                     # parser  - switch on parser debug
                     # stack   - switch on stack debug
                     # file    - switch on file debug
                     # !parser - switch off parser debug
                     # !stack  - switch off stack debug
                     # !file   - switch off file debug
    );

=head2 method extract

The default pot_dir is "./".

Call

    $extractor->extract({file_name => 'dir/filename.pl'});

to extract "dir/filename.pl" and write "$pot_dir/dir/filename.pl.pot".

Call

    open my $file_handle, '<', 'dir/filename.pl'
        or croak "Can no open file dir/filename.pl\n$OS_ERROR";
    $extractor->extract({file_name => 'filename', file_handle => $file_handle});

to extract "dir/filename.pl" and write "$pot_dir/filename.pot".

Call

    $extractor->extract({source_file_name => 'dir/filename.pl', file_name => 'file_name2'});

to extract "dir/filename.pl" and write "$pot_dir/filename2.pot".

Call

    open my $file_handle, '<', 'dir/filename.pl'
        or croak "Can no open file dir/filename.pl\n$OS_ERROR";
    $extractor->extract({source_file_name => 'dir/filename.pl', file_handle => $file_handle, file_name => 'file_name2'});

to extract "dir/filename.pl" and write "$pot_dir/filename2.pot".

=head2 method debug

Switch on the debug to see on STDERR how the rules are handled.
Inherit of this class and write your own debug method if needed.

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