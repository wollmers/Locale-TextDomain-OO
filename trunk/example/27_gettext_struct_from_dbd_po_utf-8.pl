#!perl -T

use strict;
use warnings;
use utf8;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
require DBI;
require DBD::PO; DBD::PO->init(qw(:plural));
require Locale::TextDomain::OO;
require Locale::Messages::OO::Struct;
use Locale::TextDomain::OO::FunctionalInterface qw(bind_object);

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test';

my $loc = Locale::TextDomain::OO->new(
    gettext_object => Locale::Messages::OO::Struct->new(\my %struct),
    text_domain    => $text_domain,
    search_dirs    => [qw(./LocaleData)],
);

# find the database for the expected language
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
$dbh->{po_tables}->{$text_domain} = {file => "$text_domain.po"};

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
%struct = (
    $text_domain => {
        plural_ref => $loc->get_function_ref_plural($plural_forms),
        array_ref  => \@array,
    },
);

# all unicode chars encode to UTF-8
binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

# allow functions to call object methods
bind_object($loc);

# run all translations
() = print map {"$_\n"}
    __(
        'book',
    ),
    __(
        '§ book',
    ),
    __n(
        '§§ book',
        '§§ books',
        0,
    ),
    __n(
        '§§ book',
        '§§ books',
        1,
    ),
    __n(
        '§§ book',
        '§§ books',
        2,
    ),
    __p(
        'c',
        'c book',
    ),
    __p(
        'c§',
        'c§ book',
    );

# $Id$

__END__

Output:

книга
§ книга
§§ книг
§§ книга
§§ книги
c книга
c§ книга