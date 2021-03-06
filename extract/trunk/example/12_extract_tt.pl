#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::TT;

my $extractor = Locale::TextDomain::OO::Extract::TT->new(
    po_charset => 'UTF-8',
);

my $filename = './files_to_extract/template.tt';
open my $filehandle, '< :encoding(UTF-8)', $filename ## no critic (BriefOpen)
    or croak "Can not open file $filename\n$OS_ERROR";
$extractor->extract({
    source_filename      => 'template.tt',
    source_filehandle    => $filehandle,
    destination_filename => 'template.pot',
});

binmode STDOUT, 'encoding(UTF-8)'
    or croak "Can not binmode STDOUT\n$OS_ERROR";

$filename = 'template.pot';
open $filehandle, '< :encoding(UTF-8)', $filename
    or croak "Can not open $filename\n$OS_ERROR";
() = print {*STDOUT} <$filehandle>;
() = close $filehandle;

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

#: template.tt:9
msgid "Text Ä"
msgstr ""

#: template.tt:13
msgid "Text Ö"
msgstr ""

#: template.tt:16
msgid "Text Ü"
msgstr ""