package Locale::TextDomain::OO::Extract;

use Moose;
use MooseX::StrictConstructor;
#use MooseX::FollowPBP;
use MooseX::Accessors::ReadWritePrivate;
use Carp qw(confess);
use English qw(-no_match_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Clone qw(clone); # clones not recursive
use DBI ();
use DBD::PO ();

our $VERSION = '0.05';

sub init {
    my (undef, @more) = @_;

    return DBD::PO->init(@more);
}

for my $name (qw(preprocess_code parameter_mapping_code)) {
    has $name => (
        is         => 'rw',
        isa        => 'CodeRef',
        lazy_build => 1,
    );
}
has start_rule => (
    is => 'rw',
    isa => 'RegexpRef',
    lazy_build => 1,
);
for my $name (qw(run_debug pot_dir pot_charset pot_header)) {
    has $name => (
        is         => 'rw',
        isa        => 'Str',
        lazy_build => 1,
    );
}
has rules => (
    is         => 'rw',
    isa        => 'ArrayRef',
    lazy_build => 1,
);
has is_append => (
    is         => 'rw',
    isa        => 'Bool',
    lazy_build => 1,
);
has content_ref => (
    is         => 'rwp',
    isa        => 'ScalarRef',
    lazy_build => 1,
    init_args  => undef,
);
has references => (
    is         => 'rwp',
    isa        => 'ArrayRef',
    lazy_build => 1,
    init_args  => undef,
);

sub debug {
    my ($self, $message) = @_;

    defined $message
        or return $self->debug('undef');
    () = print {*STDERR} "\n# $message";

    return $self;
}

my %debug_switch_of = (
    ':all' => ~ 0,
    parser => 2 ** 0,
    data   => 2 ** 1,
    file   => 2 ** 2,
);

sub _debug {
    my ($self, $group, @messages) = @_;

    my $run_debug = $self->get_run_debug()
        or return $self;
    my $debug = 0;
    DEBUG: for ( split m{\s+}xms, $run_debug ) {
        my $switch = $_;
        my $is_not = $switch =~ s{\A !}{}xms;
        if ( exists $debug_switch_of{$switch} ) {
            if ($is_not) {
                $debug &= ~ $debug_switch_of{$switch};
            }
            else {
                $debug |= $debug_switch_of{$switch};
            }
        }
        else {
            confess "Unknwon debug switch $_";
        }
    }
    $debug & $debug_switch_of{$group}
        or return $self;

    for my $line ( map { split m{\n}xms, $_ } @messages ) {
        $self->debug($line);
    }

    return $self;
}

sub _parse_pos {
    my $self = shift;

    my $regex = $self->get_start_rule();
    my $content_ref = $self->get_content_ref();
    my @references;
    while ( ${$content_ref} =~ m{\G .*? ($regex)}xmsgc ) {
        push @references, {
            start_pos => pos( ${$content_ref} ) - length $1,
        };
    }
    $self->_set_references(\@references);

    return $self;
}

sub _parse_rules {
    my $self = shift;

    my $content_ref = $self->get_content_ref();
    for my $reference ( @{ $self->get_references() } ) {
        my $rules       = clone $self->get_rules();
        my $pos         = $reference->{start_pos};
        my $has_matched = 0;
        $self->_debug('parser', "Starting at pos $pos.");
        my (@parent_rules, @parent_pos);
        RULE: {
            my $rule = shift @{$rules};
            if (! $rule) {
                $self->_debug('parser', 'No more rules found.');
                if (@parent_rules) {
                    $rules = pop @parent_rules;
                    ()     = pop @parent_pos;
                    $self->_debug('parser', 'Going back to parent.');
                    redo RULE;
                }
                last RULE;
            }
            # goto child
            if ( ref $rule eq 'ARRAY' ) {
                push @parent_rules, $rules;
                push @parent_pos,   $pos;
                $rules = clone $rule;
                $self->_debug('parser', 'Going to child.');
                redo RULE;
            }
            # alternative
            if ( $rule eq 'OR' ) {
                if ( $has_matched ) {
                    $rules       = pop @parent_rules;
                    ()           = pop @parent_pos;
                    $has_matched = 0;
                    $self->_debug('parser', 'Ignore alternative.');
                    redo RULE;
                }
                $self->_debug('parser', 'Try alternative.');
                redo RULE;
            }
            pos ${ $content_ref } = $pos;
            $self->_debug('parser', "Set the current pos to $pos.");
            $has_matched
                = my ($match, @result)
                = ${$content_ref} =~ m{\G ($rule)}xms;
            if ($has_matched) {
                push @{ $reference->{parameter} }, @result;
                $pos += length $match;
                $self->_debug(
                    'parser',
                    qq{Rule $rule has matched:},
                    ( split m{\n}xms, $match ),
                    "The current pos is $pos.",
                );
                redo RULE;
            }
            $rules = pop @parent_rules;
            $pos   = pop @parent_pos;
            $self->_debug(
                'parser',
                "Rule $rule has not matched.",
                'Going back to parent.',
            );
            redo RULE;
        }
    }

    return $self;
}

sub _cleanup {
    my $self = shift;

    my $references = $self->get_references();
    my $index = 0;
    @{$references} = grep {
        exists $_->{parameter}
    } @{$references};

    return $self;
}

sub _calculate_reference {
    my $self = shift;

    my $content_ref = $self->get_content_ref();
    for my $reference ( @{ $self->get_references() } ) {
        my $pre_match = substr ${$content_ref}, 0, $reference->{start_pos};
        my $newline_count = $pre_match =~ tr{\n}{\n};
        $reference->{line_number} = $newline_count + 1;
    }

    return $self;
}

sub _calculate_pot_data {
    my ($self, $file_name) = @_;

    if ( $self->get_run_debug() ) {
        require Data::Dumper;
        $self->_debug(
            'data',
            Data::Dumper
                ->new([$self->get_references()], [qw(parameters)])
                ->Sortkeys(1)
                ->Dump()
        );
    }
    my $parameter_mapping_code = $self->get_parameter_mapping_code();
    REFERENCE:
    for my $reference ( @{ $self->get_references() } ) {
        my $parameter = $parameter_mapping_code->(
            delete $reference->{parameter},
        ) or next REFERENCE;
        $reference->{pot_data} = {(
            reference => "$file_name:$reference->{line_number}",
            %{$parameter},
        )};
    }

    return $self;
}

sub _store_pot_file {
    my ($self, $file_name) = @_;

    # create a new pot file
    my $dbh = DBI->connect(
        'DBI:PO:'
        . (
            join q{;}, (
                (
                    defined $self->get_pot_dir()
                    ? join q{=}, 'f_dir', $self->get_pot_dir()
                    : ()
                ),
                (
                    defined $self->get_pot_charset()
                    ? join q{=}, 'po_charset', $self->get_pot_charset()
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
    if (! -f "$self->get_pot_dir()/$file_name.pot") {
        $dbh->do(<<'EO_SQL');
            CREATE TABLE pot (
                reference    VARCHAR,
                msgctxt      VARCHAR,
                msgid        VARCHAR,
                msgid_plural VARCHAR
            )
EO_SQL
    }

    # write the header
    $self->_debug('file', "Write header of $file_name.pot");
    my $header_msgstr = $dbh->func(
        {(
            'Plural-Forms' => 'nplurals=2; plural=n != 1;',
            %{ $self->get_pot_header() || {} },
        )},
        'build_header_msgstr',
    );
    $dbh->do(<<'EO_SQL', undef, $header_msgstr);
        INSERT INTO pot
        (msgstr)
        VALUES (?)
EO_SQL

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
    REFERENCE:
    for ( @{ $self->get_references() } ) {
        my $entry = $_->{pot_data}
            or next REFERENCE;
        $sth_select->execute(
            map {
                defined $_ ? $_ : q{};
            } @{$entry}{ qw(msgctxt msgid msgid_plural) }
        );
        my ($reference) = $sth_select->fetchrow_array();
        if ($reference && length $reference) {
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

sub extract {
    my ($self, $file_name, $file_handle) = @_;

    defined $file_name
        or confess 'No file name given';
    if (! ref $file_handle) {
        open $file_handle, '<', $file_name ## no critic (BriefOpen)
            or confess "Can not open file $file_name\n$OS_ERROR";
    }

    local $INPUT_RECORD_SEPARATOR = ();
    $self->_set_content_ref(\<$file_handle>);
    () = close $file_handle;

    if ( $self->get_preprocess_code() ) {
        $self->get_preprocess_code()->( $self->get_content_ref() );
    }
    $self->_parse_pos();
    $self->_parse_rules();
    $self->_cleanup();
    $self->_calculate_reference();
    $self->_calculate_pot_data($file_name);
    $self->_store_pot_file($file_name);

    return $self;
}

no Moose;
__PACKAGE__->meta()->make_immutable();

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
How to initialize see L<DBD::PO>.

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
    );

=head2 method extract

The default pot_dir is "./".

Call

    $extractor->extract({file_name => 'dir/filename.pl'});

to extract "dir/filename.pl" to have a "$pot_dir/dir/filename.pl.pot".

Call

    open my $file_handle, '<', 'dir/filename.pl'
        or confess "Can no open file dir/filename.pl\n$OS_ERROR";
    $extractor->extract({
        file_name  => 'filename',
        filehandle => $file_handle,
    });

to extract "dir/filename.pl" to have a "$pot_dir/filename.pot".

Call

    $extractor->extract({
        file_name        => 'filename',
        source_file_name => 'dir/a.pl',
    });
    $extractor->extract({
        file_name        => 'filename',
        source_file_name => 'dir/b.pl',
    });

to extract "dir/a.pl" and "dir/b.pl" to have a "$pot_dir/filename.pot".

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

Copyright (c) 2009,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut