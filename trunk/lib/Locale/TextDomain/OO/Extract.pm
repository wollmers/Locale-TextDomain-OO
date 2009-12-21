package Locale::TextDomain::OO::Extract;

use strict;
use warnings;

use version; our $VERSION = qv('0.04');

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Clone qw(clone); # clones not recursive
require DBI;
require DBD::PO; DBD::PO->init( qw(:plural) );

my $perl_remove_pod_ref = sub {
    my $content_ref = shift;

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

    return;
};

my $perl_parameter_mapping_ref = sub {
    my $parameter = shift;

    my $context_parameter = shift @{$parameter};

    return {
        msgctxt      => $context_parameter =~ m{p}xms
                        ? $context_parameter
                        : undef,
        msgid        => scalar shift @{$parameter},
        msgid_plural => scalar shift @{$parameter},
    };
};

my $context_rule
    = my $text_rule
    = my $singular_rule
    = my $plural_rule
    = [
        qr{'}xms,
        qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
        qr{'}xms,
        'RETURN',
    ];

my $komma_rule               = qr{,}xms;
my $optional_whitespace_rule = qr{\s*}xms;

my $perl_start_rule = qr{__ n?p?x? \(}xms;
my $perl_rules = [
    [
        qr{__ (x?) \(}xms,
        $optional_whitespace_rule,
        $text_rule,
    ],
    [
        qr{__ (nx?) \(}xms,
        $optional_whitespace_rule,
        $singular_rule,
        $optional_whitespace_rule,
        $komma_rule,
        $optional_whitespace_rule,
        $plural_rule,
     ],
    [
        qr{__ (px?) \(}xms,
        $optional_whitespace_rule,
        $context_rule,
        $optional_whitespace_rule,
        $komma_rule,
        $optional_whitespace_rule,
        $text_rule,
    ],
    [
        qr{__ (npx?) \(}xms,
        $optional_whitespace_rule,
        $context_rule,
        $optional_whitespace_rule,
        $komma_rule,
        $optional_whitespace_rule,
        $singular_rule,
        $optional_whitespace_rule,
        $komma_rule,
        $optional_whitespace_rule,
        $plural_rule,
    ],
];

sub new {
    my ($class, %init) = @_;

    my $self = bless {}, $class;

    # prepare the file and the encoding
    $self->_set_preprocess_ref(
        ( defined $init{preprocess_ref} && ref $init{preprocess_ref} eq 'CODE' )
        ? delete $init{preprocess_ref}
        : $perl_remove_pod_ref
    );

    # how to find such lines
    $self->_set_start_rule(
        defined $init{start_rule}
        ? delete $init{start_rule}
        : $perl_start_rule
    );

    # how to find the parameters
    $self->_set_rules(
        defined $init{rules}
        ? delete $init{rules}
        : $perl_rules
    );

    # debug output for other rules than perl
    $self->_set_is_debug(
        defined $init{is_debug}
        ? delete $init{is_debug}
        : ()
    );

    # how to map the parameters to pot file
    $self->_set_parameter_mapping_ref(
        defined $init{parameter_mapping_ref}
        ? delete $init{parameter_mapping_ref}
        : $perl_parameter_mapping_ref
    );

    # where to store the pot file
    if ( defined $init{pot_dir} ) {
        $self->_set_pot_dir( delete $init{pot_dir} );
    }

    # how to store the pot file
    if ( defined $init{pot_charset} ) {
        $self->_set_pot_charset( delete $init{pot_charset} );
    }

    # error
    my $keys = join ', ', keys %init;
    if ($keys) {
        croak "Unknown parameter: $keys";
    }

    return $self;
}

my @names = qw(
    preprocess_ref start_rule rules is_debug parameter_mapping_ref
    pot_dir pot_charset
    content_ref references_ref
);

for my $name (@names) {
    no strict qw(refs);       ## no critic (NoStrict)
    no warnings qw(redefine); ## no critic (NoWarnings)
    *{"_set_$name"} = sub {
        my ($self, $data) = @_;

        $self->{$name} = $data;

        return $self;
    };
    *{"_get_$name"} = sub {
        return shift->{$name};
    };
}

sub debug {
    my ($self, $message) = @_;

    defined $message
        or return $self->debug('undef');
    () = print {*STDERR} "\n# $message";

    return $self;
}

sub _debug {
    my ($self, @messages) = @_;

    $self->_get_is_debug()
        or return $self;
    for my $message (@messages) {
        $self->debug($message);
    }

    return $self;
}

sub _parse_pos {
    my $self = shift;

    my $regex = $self->_get_start_rule();
    my $content_ref = $self->_get_content_ref();
    my @references;
    while ( ${$content_ref} =~ m{\G .*? ($regex)}xmsgc ) {
        push @references, {
            start_pos => pos( ${$content_ref} ) - length $1,
        };
    }
    $self->_set_references_ref(\@references);

    return $self;
}

sub _parse_rules {
    my $self = shift;

    my $content_ref = $self->_get_content_ref();
    for my $reference ( @{ $self->_get_references_ref() } ) {
        my $rules = clone $self->_get_rules();
        my $pos   = $reference->{start_pos};
        $self->_debug("Starting at pos $pos.");
        my (@parent_rules, @parent_pos);
        RULE: {
            my $rule = shift @{$rules};
            # goto parent an find next alternative
            if (! $rule) {
                $self->_debug('No more rules found.');
                if (@parent_rules) {
                    $rules = pop @parent_rules;
                    $pos   = pop @parent_pos;
                    $self->_debug(
                        'Should try next alternative.',
                        'Going back to parent.',
                        "Current pos is $pos.",
                    );
                    redo RULE;
                }
                last RULE;
            }
            # goto child
            if ( ref $rule eq 'ARRAY' ) {
                push @parent_rules, $rules;
                push @parent_pos,   $pos;
                $rules = clone $rule;
                $self->_debug('Going to child.');
                redo RULE;
            }
            # end of child, goto parent
            elsif ( $rule eq 'RETURN') {
                $rules = pop @parent_rules;
                pop @parent_pos;
                $self->_debug(
                    'End of child detected.',
                    'Going back to parent.',
                    "Current pos is $pos.",
                );
                redo RULE;
            }
            pos ${ $content_ref } = $pos;
            $self->_debug("Set the current pos to $pos.");
            my $has_matched
                = my ($match, @result)
                = ${$content_ref} =~ m{\G ($rule)}xms;
            if ($has_matched) {
                push @{ $reference->{parameter} }, @result;
                $pos += length $match;
                $self->_debug(
                    qq{Rule $rule has matched:},
                    ( split m{\n}xms, $match ),
                    "The current pos is $pos.",
                );
            }
            else {
                $rules = pop @parent_rules;
                $pos   = pop @parent_pos;
                $self->_debug(
                    "Rule $rule has not matched.",
                    'Going back to parent.',
                    "The current pos is $pos.",
                );
            }
            redo RULE;
        }
    }

    return $self;
}

sub _cleanup {
    my $self = shift;

    my $references_ref = $self->_get_references_ref();
    my $index = 0;
    @{$references_ref} = grep { exists $_->{parameter} } @{$references_ref};

    return $self;
}

sub _calculate_reference {
    my $self = shift;

    my $content_ref = $self->_get_content_ref();
    for my $reference ( @{ $self->_get_references_ref() } ) {
        my $pre_match = substr ${$content_ref}, 0, $reference->{start_pos};
        my $newline_count = $pre_match =~ tr{\n}{\n};
        $reference->{line_number} = $newline_count + 1;
    }

    return $self;
}

sub _calculate_pot_data {
    my ($self, $file_name) = @_;

    my $parameter_mapping_ref = $self->_get_parameter_mapping_ref();
    for my $reference ( @{ $self->_get_references_ref() } ) {
        my $parameter = $parameter_mapping_ref->(
            delete $reference->{parameter},
        );
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
    $dbh->do('DROP TABLE IF EXISTS pot');
    $dbh->do(<<'EO_SQL');
        CREATE TABLE pot (
            reference    VARCHAR,
            msgctxt      VARCHAR,
            msgid        VARCHAR,
            msgid_plural VARCHAR
        )
EO_SQL

    # write the header
    my $header_msgstr = $dbh->func(
        { 'Plural-Forms' => 'nplurals=2; plural=n != 1;' },
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
    for my $reference ( @{ $self->_get_references_ref() } ) {
        my $entry = $reference->{pot_data};
        $sth_select->execute(
            @{$entry}{ qw(msgctxt msgid msgid_plural) },
        );
        my ($reference) = $sth_select->fetchrow_array();
        if ($reference && length $reference) {
            # Concat with the po_separator. The default is "\n".
            $reference = "$reference\n$entry->{reference}";
            $sth_update->execute(
                $reference,
                @{$entry}{ qw(msgctxt msgid msgid_plural) },
            );
        }
        else {
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
        or croak 'No file name given';
    if (! ref $file_handle) {
        open $file_handle, '<', $file_name ## no critic (BriefOpen)
            or croak "Can not open file $file_name\n$OS_ERROR";
    }

    local $INPUT_RECORD_SEPARATOR = ();
    $self->_set_content_ref(\<$file_handle>);
    () = close $file_handle;

    $self->_get_preprocess_ref()->( $self->_get_content_ref() );
    $self->_parse_pos();
    $self->_parse_rules();
    $self->_cleanup();
    $self->_calculate_reference();
    $self->_calculate_pot_data($file_name);
    $self->_store_pot_file($file_name);

    return $self;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Extract - Extract internationalization data as pot file

$Id$

$HeadURL$

=head1 VERSION

0.04

=head1 DESCRIPTION

This module extract internationalizations data and stores this in a pot file.
The default is to extract a pl or pm file.
Otherwise overwrite the default rules.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::Extract;

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.
The defaults are to parse Perl pl or pm files.

    my $extractor = Locale::TextDomain::OO::Extract->new(
        # prepare the file and the encoding
        preprocess_ref => sub {
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
                qr{__ (x?) \(}xms,
                qr{\s*}xms,
                # You can reuse this reference
                # because the last value is 'RETURN'
                # and so this is not an alternative.
                # It is something like a sub.
                [
                    qr{'}xms,
                    qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
                    qr{'}xms,
                    'RETURN',
                ],
            ],
            [
                # next alternative e.g.
                # __n( 'context' , 'text'
                # __nx( 'context' , 'text'
                ...
            ],
        ],

        # debug output for other rules than perl
        is_debug => $boolean, # to check own writen rules

        # how to map the parameters to pot file
        parameter_mapping_ref => sub {
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

Carp

English

Clone

DBI

DBD::PO

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
