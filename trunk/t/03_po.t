#!perl -T

use strict;
use warnings;

use Test::More tests => 16 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Carp qw(croak);
use English qw(-no_match_vars $EVAL_ERROR);
require DBI;
require DBD::PO; DBD::PO->init(qw(:plural));

BEGIN {
    require_ok('Locale::TextDomain::OO');
    use_ok('Locale::Messages::AnyObject', qw(set_object));
    require_ok('Locale::Messages::Struct');
}

$ENV{LANGUAGE}  = 'de_DE';
my $text_domain = 'test';

my $loc;
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            gettext_package => 'Locale::Messages::AnyObject',
            text_domain     => $text_domain,
            search_dirs     => [qw(./t/LocaleData/)],
        );
    },
    'create extended object',
);

# find the database for the expected language
# here fallback to 'de'
my $file_path = $loc->get_file_path($text_domain, '.po');

# connect
my $dbh = DBI->connect(
    'DBI:PO:'
    . "f_dir=$file_path;"
    . 'po_charset=utf-8',
    undef,
    undef,
    {
        RaiseError => 1,
        PrintError => 0,
    },
) or croak DBI->errstr();
$dbh->{po_tables}->{'test'} = {file => 'test.po'};

# Read the header of po-file and extract the 'Plural-Forms'.
my $plural_forms = $dbh->func(
    {
        table => $text_domain,
    },
    'Plural-Forms',
    'get_header_msgstr_data',
) or croak 'Can not extract plural_forms';

# check and build the SQL for the count of the plural forms
my $msgstr_n = join ', ', map {
    "msgstr_$_"
} (0 .. $loc->get_nplurals($plural_forms));

my $sth = $dbh->prepare(<<"EO_SQL");
    SELECT msgctxt, msgid, msgid_plural, msgstr, $msgstr_n
    FROM $text_domain
    WHERE msgid <> ''
EO_SQL

# read all entrys of the full po-file
$sth->execute();
my @array;
while ( my $hashref = $sth->fetchrow_hashref() ) {
    push @array, { %{$hashref} },
}
$sth->finish();

$dbh->disconnect();

# build the struct and bind the struct as object to the text domain
my %struct = (
    $text_domain => {
        plural_ref => $loc->get_function_ref_plural($plural_forms),
        array_ref  => \@array,
    },
);
set_object($text_domain => Locale::Messages::Struct->new(\%struct));

# check all translation
eq_or_diff(
    $loc->__(
        'This is a text.',
    ),
    'Das ist ein Text.',
    '__',
);

eq_or_diff(
    $loc->__x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    'Steffen programmiert Perl.',
    '__x',
);

eq_or_diff(
    $loc->__n(
        'Singular',
        'Plural',
        1,
    ),
    'Einzahl',
    '__n',
);
eq_or_diff(
    $loc->__n(
        'Singular',
        'Plural',
        3,
    ),
    'Mehrzahl',
    '__n',
);

eq_or_diff(
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 Regal',
    '__nx',
);
eq_or_diff(
    $loc->__nx(
        '{num} shelf',
        '{num} shelves',
        3,
        num => 3,
    ),
    '3 Regale',
    '__nx',
);

eq_or_diff(
    $loc->__p(
        'maskulin',
        'Dear',
    ),
    'Sehr geehrter Herr',
    '__p',
);

eq_or_diff(
    $loc->__px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ),
    'Sehr geehrter Herr Winkler',
    '__px',
);

eq_or_diff(
    $loc->__np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    'gutes Regal',
    '__np',
);
eq_or_diff(
    $loc->__np(
        'better',
        'shelf',
        'shelves',
        3,
    ),
    'gute Regale',
    '__np',
);

eq_or_diff(
    $loc->__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    '1 gutes Regal',
    '__npx',
);
eq_or_diff(
    $loc->__npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        3,
        num => 3,
    ),
    '3 gute Regale',
    '__npx',
);