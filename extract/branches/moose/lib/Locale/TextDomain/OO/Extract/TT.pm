package Locale::TextDomain::OO::Extract::TT;

use strict;
use warnings;

use version; our $VERSION = qv('0.05');

use parent qw(Locale::TextDomain::OO::Extract);

my $text_rule
    = [
        qr{'}xms,
        qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
        qr{'}xms,
    ];

#my $komma_rule = qr{\s* , \s*}xms;

my $start_rule = qr{\[ \% \s* l \(}xms;

my $rules = [
    qr{\[ \% \s* l() \( \s*}xms,
    $text_rule,
];

my $parameter_mapping_code = sub {
    my $parameter = shift;

    my $extra_parameter = shift @{$parameter};
    @{$parameter}
        or return;

    return {
        msgctxt      => $extra_parameter =~ m{p}xms
                        ? scalar shift @{$parameter}
                        : undef,
        msgid        => scalar shift @{$parameter},
        msgid_plural => scalar shift @{$parameter},
    };
};

sub new {
    my ($class, %init) = @_;

    return $class->SUPER::new(
        start_rule             => $start_rule,
        rules                  => $rules,
        parameter_mapping_code => $parameter_mapping_code,
        %init,
    );
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Extract::TT
- Extracts internationalization data from TemplateToolkit code

$Id: TT.pm 271 2010-01-16 07:37:06Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract/TT.pm $

=head1 VERSION

0.04

=head1 DESCRIPTION

This module extracts internationalization data from Template code.

Implemented rules:

 [%l('...

Whitespace is allowed everywhere.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract::TT;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.
See Locale::TextDomain::OO::Extract to replace the defaults.

    my $extractor = Locale::TextDomain::OO::Extract::TT->new(
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

    $extractor->extract('dir/filename.tt');

to extract "dir/filename.tt" to have a "$pot_dir/dir/filename.tt.pot".

Call

    open my $file_handle, '<', 'dir/filename.tt'
        or croak "Can no open file dir/filename.tt\n$OS_ERROR";
    $extractor->extract('filename', $file_handle);

to extract "dir/filename.tt" to have a "$pot_dir/filename.pot".

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

Template

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