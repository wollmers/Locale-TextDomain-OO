package Locale::TextDomain::OO::Extract;

use strict;
use warnings;

use version; our $VERSION = qv('0.04');

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Clone qw(clone);
require DBI;
require DBD::PO; DBD::PO->init( qw(:plural) );

my $perl_remove_pod = sub {
    return;
};

my $context_rule
    = my $text_rule
    = my $singular_rule
    = my $plural_rule
    = [
        qr{'}xms,
        qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
        qr{'}xms,
    ];
my $komma_rule               = qr{,}xms;
my $optional_whitespace_rule = qr{\s*}xms;
my $perl_start_rule          = qr{__ n?p?x? \(}xms;
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

    $self->_set_pot_dir(
        defined $init{pot_dir}
        ? delete $init{pot_dir}
        : q{.}
    );
    $self->_set_preprocess(
        ( defined $init{preprocess} && ref $init{preprocess} eq 'CODE' )
        ? delete $init{preprocess}
        : $perl_remove_pod
    );
    $self->_set_start_rule(
        defined $init{start_rule}
        ? delete $init{start_rule}
        : $perl_start_rule
    );
    $self->_set_rules(
        defined $init{rules}
        ? delete $init{rules}
        : $perl_rules
    );

    return $self;
}

for my $name ( qw(pot_dir preprocess start_rule rules content_ref references_ref) ) {
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
        my (@parent_rules, @parent_pos);
        RULE: {
            my $rule = shift @{$rules};
            # goto parent
            if (! $rule && @parent_rules) {
                $rules = pop @parent_rules;
                $pos   = pop @parent_pos;
                redo RULE;
            }
            $rule
               or last RULE;
            # goto child
            if ( ref $rule eq 'ARRAY' ) {
                push @parent_rules, $rules;
                push @parent_pos,   $pos;
                $rules = $rule;
                redo RULE;
            }
            pos ${ $content_ref } = $pos;
            my $has_matched
                = my ($match, @result)
                = ${$content_ref} =~ m{\G ($rule)}xms;
            if ($has_matched) {
                push @{ $reference->{parameter} }, @result;
                $pos += length $match;
print STDERR "\n+++ $rule";
            }
            else {
                $rules = pop @parent_rules;
                $pos   = pop @parent_pos;
print STDERR "\n--- $rule";
            }
            redo RULE;
        }
    }

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

sub extract {
    my ($self, $file_name_or_open_handle) = @_;

    my ($file_name, $file_handle);
    if (ref $file_name_or_open_handle) {
        $file_name
            = $file_handle
            = $file_name_or_open_handle;
    }
    else {
        $file_name = $file_name_or_open_handle;
        open $file_handle, '<', $file_name
            or croak "Can not open file $file_name\n$OS_ERROR";
    }

    local $INPUT_RECORD_SEPARATOR = ();
    $self->_set_content_ref(\<$file_handle>);
    () = close $file_handle;

    $self->_get_preprocess()->( $self->_get_content_ref() );
    $self->_parse_pos();
    $self->_parse_rules();
    $self->_calculate_reference();
use Data::Dumper; die Dumper $self->_get_references_ref();
    $self->_store_pot();

    return $self;
}

1;

__END__

        # found
        $has_matched ||= $text =~ s{$rule}{}xms; # delete found string
        my $format = shift @result || q{};
        push @pot_data, {
            # where found
            reference    => __FILE__ . ":$line_number",
            # optional context
            msgctxt      => $format =~ m{p}xms
                            ? shift @result
                            # DBD::PO fetch NULL as empty string
                            : q{},
            # the original text
            msgid        => shift @result,
            # optional origninal text in the plural form
            msgid_plural => $format =~ m{n}xms
                            ? shift @result
                            # DBD::PO fetch NULL as empty string
                           : q{},
        };
    }
    if ($has_matched) {
        @lines[($line_number - 1) .. $#lines] = split m{\n}xms, $text;
    }
    ++$line_number;
}

# Deleting the pot file if this exists,
# so that this example can be going on repeatedly.
unlink 'extract.pot';

# create a new pot file
my $dbh = DBI->connect(
    'DBI:PO:po_charset=UTF-8',
    undef,
    undef,
    {RaiseError => 1},
);
$dbh->do(<<'EO_SQL');
     CREATE TABLE extract.pot (
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
     INSERT INTO extract.pot
     (msgstr)
     VALUES (?)
EO_SQL

# to check if the entry is known
my $sth_select = $dbh->prepare(<<'EO_SQL');
     SELECT reference
     FROM extract.pot
     WHERE
         msgctxt=?
         AND msgid=?
         AND msgid_plural=?
EO_SQL

# to insert a new entry
my $sth_insert = $dbh->prepare(<<'EO_SQL');
     INSERT INTO extract.pot
     (reference, msgctxt, msgid, msgid_plural)
     VALUES (?, ?, ?, ?)
EO_SQL

# to add the next reference to a known entry
my $sth_update = $dbh->prepare(<<'EO_SQL');
     UPDATE extract.pot
     SET reference=?
     WHERE
         msgctxt=?
         AND msgid=?
         AND msgid_plural=?
EO_SQL

# write entrys
for my $entry (@pot_data) {
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

1;

__END__

# $Id$