package Locale::TextDomain::OO::Extract;

use strict;
use warnings;

our $VERSION = '0.05';

use parent qw(Locale::TextDomain::OO::RegexExtractor);

use Carp qw(croak);
require DBI;
require DBD::PO; DBD::PO->init(':plural');

sub init {
    my (undef, @more) = @_;

    return DBD::PO->init(@more);
}

my @names = qw(pot_dir pot_charset pot_header is_append);

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
        *{"_is_$data_name"} = sub {
            return shift->{$data_name};
        };
    }
    else {
        *{"_get_$data_name"} = sub {
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

    # where to store the pot file
    if ( defined $my_init{pot_dir} ) {
        $self->_set_pot_dir( delete $my_init{pot_dir} );
    }

    # how to store the pot file
    if ( defined $my_init{pot_charset} ) {
        $self->_set_pot_charset( delete $my_init{pot_charset} );
    }

    # how to store the pot file
    if ( ref $my_init{pot_header} eq 'HASH' ) {
        $self->_set_pot_header( delete $my_init{pot_header} );
    }

    # how write the pot file
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
    my ($self, $file_name) = @_;

    # create a new pot file
    my $dbh = DBI->connect(
        'DBI:PO:'
        . (
            join q{;}, (
                (
                    defined $self->_get_pot_dir()
                    ? join q{=}, 'f_dir', $self->_get_pot_dir()
                    : ()
                ),
                (
                    defined $self->_get_pot_charset()
                    ? join q{=}, 'po_charset', $self->_get_pot_charset()
                    : ()
                ),
            )
        ),
        undef,
        undef,
        {RaiseError => 1},
    );
    $dbh->{po_tables}->{pot} = {file => "$file_name.pot"};
    if (! $self->_is_append()) {
        $dbh->do('DROP TABLE IF EXISTS pot');
    }
    if (! -f ($self->_get_pot_dir() || q{.}) . "/$file_name.pot") {
        $dbh->do(<<'EO_SQL');
            CREATE TABLE pot (
                reference    VARCHAR,
                msgctxt      VARCHAR,
                msgid        VARCHAR,
                msgid_plural VARCHAR
            )
EO_SQL

        # write the header
        $self->_debug('file', "Write header of $file_name.pot");
        my $header_msgstr = $dbh->func(
            {(
                'Plural-Forms' => 'nplurals=2; plural=n != 1;',
                %{ $self->_get_pot_header() || {} },
            )},
            'build_header_msgstr',
        );
        $dbh->do(<<'EO_SQL', undef, $header_msgstr);
            INSERT INTO pot
            (msgstr)
            VALUES (?)
EO_SQL
    }

    # to check if the entry is known
    my $sth_select = $dbh->prepare(<<'EO_SQL');
        SELECT reference
        FROM pot
        WHERE
            msgctxt=?
            AND msgid=?
            AND msgid_plural=?
EO_SQL

    # to insert a new entry
    my $sth_insert = $dbh->prepare(<<'EO_SQL');
        INSERT INTO pot
        (reference, msgctxt, msgid, msgid_plural)
        VALUES (?, ?, ?, ?)
EO_SQL

    # to add the next reference to a known entry
    my $sth_update = $dbh->prepare(<<'EO_SQL');
        UPDATE pot
        SET reference=?
        WHERE
            msgctxt=?
            AND msgid=?
            AND msgid_plural=?
EO_SQL

    # write entrys
    STACK_ITEM:
    for ( @{ $self->_get_stack() } ) {
        my $entry = $_->{pot_data}
            or next STACK_ITEM;
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

0.05

=head1 DESCRIPTION

This module extracts internationalizations data and stores this in a pot file.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract;

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
        # prepare the file and the encoding
        preprocess_code => sub {
            my $content_ref = shift;

            ...

            return;
        },

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

        # debug output for other rules than perl
        run_debug => ':all !parser', # debug all but not the parser
                     # :all    - switch on all debugs
                     # parser  - switch on parser debug
                     # data    - switch on data debug
                     # file    - switch on file debug
                     # !parser - switch off parser debug
                     # !data   - switch off data debug
                     # !file   - switch off file debug

        # how to map the parameters to pot file
        parameter_mapping_code => sub {
            my $parameter = shift;

            # The chars after __ were stored to make a decision now.
            my $context_parameter = shift @{$parameter};

            return {
                msgctxt      => $context_parameter =~ m{p}xms
                                ? $context_parameter
                                : undef,
                msgid        => scalar shift @{$parameter},
                msgid_plural => scalar shift @{$parameter},
            };
        },

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

        # write your own code to store pot file
        store_pot_code => sub {
            my $attr_ref = shift;

            my $pot_dir     = $sttr_ref->{pot_dir};     # undef or string
            my $pot_charset = $sttr_ref->{pot_charset}; # undef or string
            my $is_append   = $sttr_ref->{is_append};   # boolean
            my $pot_header  = $sttr_ref->{pot_header};  # hashref
            my $stack       = $sttr_ref->{stack};       # arrayref
            my $file_name   = $sttr_ref->{file_name};   # undef or string

            ...
        },
    );

=head2 method extract

The default pot_dir is "./".

Call

    $extractor->extract('dir/filename.pl');

to extract "dir/filename.pl" to have a "$pot_dir/dir/filename.pl.pot".

Call

    open my $file_handle, '<', 'dir/filename.pl'
        or croak "Can no open file dir/filename.pl\n$OS_ERROR";
    $extractor->extract('filename', $file_handle);

to extract "dir/filename.pl" to have a "$pot_dir/filename.pot".

=head2 method debug

Switch on the debug to see on STDERR how the rules are handled.
Inherit of this class and write your own debug method if needed.

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error message in case of unknown parameters at method new.

 Unknown parameter: ...

Undef is not a filename.

 No file name given

There is a problem in opening the file to extract.

 Can not open file ...

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

version

Carp

English

Clone

DBI

DBD::PO

=head2 dynamic require

L<Data::Dumper>

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
