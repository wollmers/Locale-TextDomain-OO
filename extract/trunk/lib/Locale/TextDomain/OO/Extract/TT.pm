package Locale::TextDomain::OO::Extract::TT;

use strict;
use warnings;

use version; our $VERSION = qv('1.00');

use parent qw(Locale::TextDomain::OO::Extract);

my $text_rule
    = [
        qr{'}xms,
        qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
        qr{'}xms,
    ];

my $start_rule = qr{\[ \% \s* l \(}xms;

my $rules = [
    qr{\[ \% \s* l() \( \s*}xms,
    $text_rule,
];

sub stack_item_mapping {
    my ($self, $stack_item) = @_;

    my $match = $stack_item->{match};
    # The chars after __ were stored to make a decision now.
    my $extra_parameter = shift @{$match};
    @{$match}
        or return;

    return {
        reference    => "$stack_item->{source_filename}:$stack_item->{line_number}",
        msgctxt      => $extra_parameter =~ m{p}xms
                        ? shift @{$match}
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

Locale::TextDomain::OO::Extract::TT
- Extracts internationalization data from TemplateToolkit code

$Id: TT.pm 271 2010-01-16 07:37:06Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract/TT.pm $

=head1 VERSION

1.00

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
        po_dir => './',

        # how to store the pot file
        # - The meaning of undef is ISO-8859-1 but use not Perl unicode.
        # - Set 'ISO-8859-1' to have a ISO-8859-1 pot file and use Perl unicode.
        # - Set 'UTF-8' to have a UTF-8 pot file and use Perl unicode.
        # And so on.
        po_charset => undef,

        # add some key value pairs to the header
        # more see documentation of DBD::PO
        po_header => { ... },

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

The default po_dir is "./".

Call

    $extractor->extract({
        source_filename      => 'dir1/filename1.tt',
        destination_filename => 'filename2.pot',
    });

to extract "dir1/filename1.tt" to "$pot_dir/filename2.pot".
The reference is "dir1/filename1.tt".

Call

    open my $filehandle, '<', 'dir1/filename1.tt'
        or croak "Can no open file dir1/filename1.tt\n$OS_ERROR";
    $extractor->extract({
        source_filename      => 'filename1',
        source_filehandle    => $filehandle,
        destination_filename => 'filename2.pot',
    });

to extract "dir1/filename1.tt" to $pot_dir/filename2.pot".
The reference is "filename1".

=head2 method stack_item_mapping

This method is expected from the abstact parent class.

    @stck_items = $self->stack_item_mapping($destination_filename);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error message in case of unknown parameters at method new.

 Unknown parameter: ...

Missing parameter.

 No source_filename given ...

 No destination filename given ...

There is a problem in opening the file to extract.

 Can not open file ...

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

Copyright (c) 2009 - 2010,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut