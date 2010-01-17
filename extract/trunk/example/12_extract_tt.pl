#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::TT;
BEGIN {
    Locale::TextDomain::OO::Extract::TT->init( qw(:plural) );
}

my $extractor = Locale::TextDomain::OO::Extract::TT->new(
    pot_charset => 'UTF-8',
);

my $file_name = './files_to_extract/template.tt';
open my $file, '< :encoding(UTF-8)', $file_name ## no critic (BriefOpen)
    or croak "Can not open file $file_name\n$OS_ERROR";
$extractor->extract('template', $file);

binmode STDOUT, 'encoding(UTF-8)'
    or croak "Can not binmode STDOUT\n$OS_ERROR";

$file_name = 'template.pot';
open $file, '< :encoding(UTF-8)', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
() = print {*STDOUT} <$file>;
() = close $file;

# only for automatic test of example
if ($ARGV[0] && $ARGV[0] eq 'cleanup') {
    unlink 'template.pot';
}

# $Id: 12_extract_tt.pl 286 2010-01-16 09:12:47Z steffenw $

__END__

Output:

msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: template:9
msgid "Text Ä"
msgstr ""

#: template:13
msgid "Text Ö"
msgstr ""

#: template:16
msgid "Text Ü"
msgstr ""

