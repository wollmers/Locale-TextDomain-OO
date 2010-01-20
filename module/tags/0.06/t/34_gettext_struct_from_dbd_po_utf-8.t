#!perl -T

use strict;
use warnings;
use utf8;

use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;
use Carp qw(croak);
require DBI;
require DBD::PO; DBD::PO->init(qw(:plural));

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::MessagesStruct');
}

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'test';

my ($loc, %struct);
lives_ok(
    sub {
        $loc = Locale::TextDomain::OO->new(
            gettext_object => Locale::TextDomain::OO::MessagesStruct->new(\%struct),
            text_domain    => $text_domain,
            search_dirs    => [qw(./t/LocaleData)],
        );
    },
    'create extended object',
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

# Read the header of the po file and extract the 'Plural-Forms'.
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

# run all translations
eq_or_diff(
    $loc->__(
        'book',
    ),
    'книга',
    '__',
);

eq_or_diff(
    $loc->__(
        '§ book',
    ),
    '§ книга',
    '__ umlaut',
);