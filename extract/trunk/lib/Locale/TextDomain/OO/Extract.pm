package Locale::TextDomain::OO::Extract;

use strict;
use warnings;

our $VERSION = '1.00';

use parent qw(Locale::TextDomain::OO::RegexExtractor);

use Carp qw(croak);
require DBI;
require DBD::PO; DBD::PO->init(':plural');

sub init {
    my (undef, @more) = @_;

    return DBD::PO->init(@more);
}

my @names = qw(po_dir po_charset po_header is_append);

for my $name (@names) {
    (my $data_name = $name) =~ s{\A is_}{}xms;
    no strict qw(refs);       ## no critic (NoStrict)
    no warnings qw(redefine); ## no critic (NoWarnings)

    *{"_set_$data_name"} = sub {
        my ($self, $data) = @_;

        $self->{$data_name} = $data;

        return $self;
    };

    if ($name ne $data_name) {
        *{"is_$data_name"} = sub {
            return shift->{$data_name};
        };
    }
    else {
        *{"get_$data_name"} = sub {
            return shift->{$data_name};
        };
    }
}

sub new {
    my ($class, %init) = @_;

    my %my_init = map {
        exists $init{$_}
        ? ( $_  => delete $init{$_} )
        : ();
    } @names;

    my $self = $class->SUPER::new(%init);

    # where to store the po file
    if ( defined $my_init{po_dir} ) {
        $self->_set_po_dir( delete $my_init{po_dir} );
    }

    # how to store the po file
    if ( defined $my_init{po_charset} ) {
        $self->_set_po_charset( delete $my_init{po_charset} );
    }

    # how to store the po file
    if ( ref $my_init{po_header} eq 'HASH' ) {
        $self->_set_po_header( delete $my_init{po_header} );
    }

    # how write the po file
    if ( exists $my_init{is_append} ) {
        $self->_set_append( delete $my_init{is_append} );
    }

    # error
    my $keys = join ', ', keys %my_init;
    if ($keys) {
        croak "Unknown parameter: $keys";
    }

    return $self;
}

sub store_data {
    my ($self, $destination_filename) = @_;

    # create a new po file
    my $dbh = DBI->connect(
        'DBI:PO:'
        . (
            join q{;}, (
                (
                    defined $self->get_po_dir()
                    ? join q{=}, 'f_dir', $self->get_po_dir()
                    : ()
                ),
                (
                    defined $self->get_po_charset()
                    ? join q{=}, 'po_charset', $self->get_po_charset()
                    : ()
                ),
            )
        ),
        undef,
        undef,
        {RaiseError => 1},
    );
    $dbh->{po_tables}->{po} = {file => $destination_filename};
    if (! $self->is_append()) {
        $dbh->do('DROP TABLE IF EXISTS po');
    }
    if (! -f ($self->get_po_dir() || q{.}) . "/$destination_filename") {
        $dbh->do(<<'EO_SQL');
            CREATE TABLE po (
                reference    VARCHAR,
                msgctxt      VARCHAR,
                msgid        VARCHAR,
                msgid_plural VARCHAR
            )
EO_SQL

        # write the header
        $self->_debug('file', "Write header of $destination_filename");
        my $header_msgstr = $dbh->func(
            {(
                'Plural-Forms' => 'nplurals=2; plural=n != 1;',
                %{ $self->get_po_header() || {} },
            )},
            'build_header_msgstr',
        );
        $dbh->do(<<'EO_SQL', undef, $header_msgstr);
            INSERT INTO po
            (msgstr)
            VALUES (?)
EO_SQL
    }

    # to check if the entry is known
    my $sth_select = $dbh->prepare(<<'EO_SQL');
        SELECT reference
        FROM po
        WHERE
            msgctxt=?
            AND msgid=?
            AND msgid_plural=?
EO_SQL

    # to insert a new entry
    my $sth_insert = $dbh->prepare(<<'EO_SQL');
        INSERT INTO po
        (reference, msgctxt, msgid, msgid_plural)
        VALUES (?, ?, ?, ?)
EO_SQL

    # to add the next reference to a known entry
    my $sth_update = $dbh->prepare(<<'EO_SQL');
        UPDATE po
        SET reference=?
        WHERE
            msgctxt=?
            AND msgid=?
            AND msgid_plural=?
EO_SQL

    # write entrys
    STACK_ITEM:
    for my $entry ( @{ $self->get_stack() } ) {
        $sth_select->execute(
            map {
                defined $_ ? $_ : q{};
            } @{$entry}{ qw(msgctxt msgid msgid_plural) }
        );
        my ($reference) = $sth_select->fetchrow_array();
        if (defined $reference && length $reference) {
            # Concat with the po_separator. The default is "\n".
            $reference = "$reference\n$entry->{reference}";
            $self->_debug(
                'file',
                "Data found, update reference to $reference",
            );
            $sth_update->execute(
                $reference,
                map {
                    defined $_ ? $_ : q{};
                } @{$entry}{ qw(msgctxt msgid msgid_plural) }
            );
        }
        else {
            $self->_debug(
                'file',
                "Data not found, insert reference $entry->{reference}",
            );
            $sth_insert->execute(
                @{$entry}{ qw(reference msgctxt msgid msgid_plural) },
            );
        }
    }

    # all finished
    for ($sth_select, $sth_insert, $sth_update) {
        $_->finish();
    }
    $dbh->disconnect();

    return $self;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Extract - Extracts internationalization data as gettext pot file

$Id: Extract.pm 271 2010-01-16 07:37:06Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract.pm $

=head1 VERSION

1.00

=head1 DESCRIPTION

This module extracts internationalizations data and stores this in a pot file.

=head1 SYNOPSIS

    use parent qw(Locale::TextDomain::OO::Extract);

    # Optional method
    # to uncomment or interpolate the file content or anything else.
    sub preprocess {
        my $self = shift;

        my $content_ref = $self->get_content_ref();
        # modify anyhow
        ${$content_ref}=~ s{\\n}{\n}xmsg;

        return $self;
    }

    # How to map the stack_item to a po entry:
    # Return an empty list to ignore the stack item.
    sub stack_item_mapping {
        my ($self, $stack_item) = @_;

        # The chars after __ were stored to make a decision now.
        my $context_parameter = shift @{$stack_item};

        return {
            msgctxt      => $context_parameter =~ m{p}xms
                            ? $context_parameter
                            : undef,
            msgid        => scalar shift @{$stack_item},
            msgid_plural => scalar shift @{$stack_item},
        };
    }

    sub store_data {
        my ($self, $destination_filename) = @_;

        my $stack = $self->get_stack();
        ...

        return $self;
    }

    my $extractor = Locale::TextDomain::OO::Extract->new(
        start_rule => qr{...}xms,
        rules      => [
            ...
        ],
    );

    # Scan file $source_filename.
    # Call method store_data with $destination_filename.
    # The reference is $source_filename.
    $extractor->extract({
        source_filename      => 'dir/source.pl',
        destination_filename => 'destination_filename',
    });

    # or
    # Scan file from open $filehandle.
    # Call method store_date with $destination_filename.
    # The reference is $source_filename.
    $extractor->extract({
        source_filename      => 'source.pl',
        source_filehande     => $source_filehandle,
        destination_filename => 'destination_filename',
    });

=head1 SUBROUTINES/METHODS

=head2 method init

This method is for initializing DBD::PO.
How to initialize, see L<DBD::PO>.
Normally you have not to do this, because the defult is:

    BEGIN {
        Locale::TextDomain::OO::Extract->init( qw(:plural) );
    }

=head2 method new

All parameters are optional.

    my $extractor = Locale::TextDomain::OO::Extract->new(
        # how to find such lines
        start_rule => qr{__ n?p?x? \(}xms

        # how to find the parameters
        rules => [
            [
                # __( 'text'
                # __x( 'text'
                qr{__ (x?) \s* \( \s*}xms,
                qr{\s*}xms,
                # You can re-use the next reference.
                # It is a subdefinition.
                [
                    qr{'}xms,
                    qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
                    qr{'}xms,
                ],
            ],
            # The next array reference describes an alternative
            # and not a subdefinition.
            'OR',
            [
                # next alternative e.g.
                # __n( 'context' , 'text'
                # __nx( 'context' , 'text'
                ...
            ],
        ],

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
        source_filename      => 'dir1/filename1.pl',
        destination_filename => 'filename2.pot',
    });

to extract "dir1/filename1.pl" to "$po_dir/filename2.pot".
The reference is "dir1/filename1.pl".

Call

    open my $filehandle, '<', 'dir1/filename1.pl'
        or croak "Can no open file dir1/filename1.pl\n$OS_ERROR";
    $extractor->extract({
        source_filename      => 'filename1',
        source_filehandle    => $filehandle,
        destination_filename => 'filename2.pot',
    });

to extract "dir1/filename1.pl" to "$po_dir/filename2.pot".
The reference is "filename1".

=head2 method debug

Switch on the debug to see on STDERR how the rules are handled.
Inherit of this class and write your own debug method if needed.

=head2 method get_po_charset

    my $charset_or_undef = $extractor->get_po_charset();

=head2 method get_po_dir

    my $po_dir_or_undef = $extractor->get_po_dir();

=head2 method get_po_header

    my $po_header or undef = $extractor->get_po_header();

=head2 method is_append

    my $boolean = $extractor->is_append();

=head2 method store_data

This method is expected from the abstact parent class.

    $extractor->store_data($filename);

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

Carp

English

DBI

DBD::PO

L<Locale::TextDomain::OO:RegexExtractor>

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