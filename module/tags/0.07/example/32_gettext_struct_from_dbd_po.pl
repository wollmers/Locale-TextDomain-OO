#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
require DBI;
require DBD::PO; DBD::PO->init(qw(:plural));
require Locale::TextDomain::OO;
require Locale::TextDomain::OO::MessagesStruct;
use Locale::TextDomain::OO::FunctionalInterface qw(bind_object);

local $ENV{LANGUAGE} = 'de_DE';
my $text_domain      = 'example';

my $loc = Locale::TextDomain::OO->new(
    gettext_object => Locale::TextDomain::OO::MessagesStruct->new(\my %struct),
    text_domain    => $text_domain,
    search_dirs    => [qw(./LocaleData/)],
);

# find the database for the expected language
# here fallback to 'de'
my $file_path = $loc->get_file_path($text_domain, '.po');

# connect
my $dbh = DBI->connect(
    'DBI:PO:'
    . "f_dir=$file_path;"
    . 'po_charset=', # pass bytes of ISO-8859-1 po file
    undef,
    undef,
    {
        RaiseError => 1,
        PrintError => 0,
    },
) or croak DBI->errstr();
$dbh->{po_tables}->{$text_domain} = {file => "$text_domain.po"};

# read the header of the po file
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

# read all entrys of the full po file
$sth->execute();
my @array;
while ( my $hashref = $sth->fetchrow_hashref() ) {
    push @array, { %{$hashref} },
}
$sth->finish();

$dbh->disconnect();

# build the struct and bind the struct as object to the text domain
%struct = (
    $text_domain => {
        plural_ref => $loc->get_function_ref_plural($plural_forms),
        array_ref  => \@array,
    },
);

# allow functions to call object methods
bind_object($loc);

# run all translations
() = print map {"$_\n"}
    __(
        'This is a text.',
    ),
    __x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    __n(
        'Singular',
        'Plural',
        1,
    ),
    __n(
        'Singular',
        'Plural',
        2,
    ),
    __nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    __nx(
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    __p(
        'maskulin',
        'Dear',
    ),
    __px(
        'maskulin',
        'Dear {name}',
        name => 'Winkler',
    ),
    __np(
        'better',
        'shelf',
        'shelves',
        1,
    ),
    __np(
        'better',
        'shelf',
        'shelves',
        2,
    ),
    __npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    __npx(
        'better',
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    );

# $Id$

__END__

Output:

Das ist ein Text.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
gute Regale
1 gutes Regal
2 gute Regale