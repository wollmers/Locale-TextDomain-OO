package Locale::TextDomain::OO::Extract;

use strict;
use warnings;

use version; our $VERSION = qv('0.04');

use Carp qw(croak);
use Storable qw(dclone);
require DBI;
require DBD::PO; DBD::PO->init( qw(:plural) );

my $context_rule
= my $text_rule
= my $singular_rule
= my $plural_rule
= [
    qr{'}xms,
    qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
    qr{'}xms,
];
my $komma_rule = qr{,}xms;
my $start_rule = qr{__}xms;
my $rules = [
    [
        qr{__ (x?) \(}xms,
        $text_rule,
    ],
    [
        qr{__ (nx?) \(}xms,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    [
        qr{__ (px?) \(}xms,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
    [
        qr{__ (npx?) \(}xms,
        $context_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
];

sub new {
    my ($class, %init) = @_;

    my $self = bless {}, $class;

    $self->_set_source_file_name(
        defined $init{source_file_name}
        ? delete $init{source_file_name}
        : croak 'input_file_name not given'
    );
    $self->_set_pot_dir(
        defined $init{pot_dir}
        ? delete $init{pot_dir}
        : q{.}
    );

    return $self;
}

my @pot_data;

# extract pot data
my $line_number = 1;
my @lines = split m{\n}xms, $text;
LINE:
for my $line (@lines) {
    $line =~ s{$start_rule}{\0}xms
        or next LINE;
    my $text = join "\n", @lines[($line_number - 1) .. $#lines];
    my $parent_rules = dclone $rules;
    my (@parameters, @parent_rules);
    RULE:
    while { my $rule = shift @{$parent_rules} ) {
        if ( ref $rule eq 'ARRAY' ) {
            push @parent_rules, $parent_rules;
            $parent_rules = $rule;
            next RULE;
        }
        my @result = s{$rule}{\0}xms;
        if (@result) {
            push @parameters, @result;
        }
        else {
            $parent_rules = pop @parent_rules;
        }
    }
}

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

