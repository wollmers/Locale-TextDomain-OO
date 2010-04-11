#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::JavaScript;

my $extractor = Locale::TextDomain::OO::Extract::JavaScript->new(
    po_charset => 'UTF-8',
);

my $filename = './files_to_extract/javascript.js';
open my $filehandle, '< :encoding(UTF-8)', $filename ## no critic (BriefOpen)
    or croak "Can not open file $filename\n$OS_ERROR";
$extractor->extract({
    source_filename      => 'javascript.js',
    source_filehandle    => $filehandle,
    destination_filename => 'javascript.pot',
});

binmode STDOUT, 'encoding(UTF-8)'
    or croak "Can not binmode STDOUT\n$OS_ERROR";

$filename = 'javascript.pot';
open $filehandle, '< :encoding(UTF-8)', $filename
    or croak "Can not open $filename\n$OS_ERROR";
() = print {*STDOUT} <$filehandle>;
() = close $filehandle;

# only for automatic test of example
if ($ARGV[0] && $ARGV[0] eq 'cleanup') {
    unlink 'javascript.pot';
}

# $Id: 13_extract_js.pl 286 2010-01-16 09:12:47Z steffenw $

__END__

Output:

msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: javascript.js:3
#: javascript.js:4
#: javascript.js:5
msgid "some string"
msgstr ""

#: javascript.js:6
msgid "this will get translated"
msgstr ""

#: javascript.js:7
msgid "text"
msgstr ""

#: javascrip.jst:8
msgid ""
"Hello World!\n"
""
msgstr ""

#: javascript.js:9
msgid "Hello %1"
msgstr ""

#: javascript.js:10
msgid "This is the %1 %2"
msgstr ""

#: javascript.js:11
#: javascript.js:15
msgid ""
"One file deleted.\n"
""
msgid_plural ""
"%d files deleted.\n"
""
msgstr[0] ""

#: javascript.js:19
msgctxt "Verb: To View"
msgid "View"
msgstr ""

#: javascript.js:20
msgctxt "Noun: A View"
msgid "View"
msgstr ""

#: javascript.js:22
msgid "one banana"
msgid_plural "%1 bananas"
msgstr[0] ""

#: javascript.js:35
msgid "MSGID 1"
msgstr ""

#: javascript.js:36
msgid "MSGID 2"
msgstr ""

#: javascript.js:37
msgid "MSGID 3"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript.js:38
msgctxt "MSGCTXT"
msgid "MSGID 4"
msgstr ""

#: javascript.js:39
msgctxt "MSGCTXT"
msgid "MSGID 5"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript.js:40
msgid "MSGID 6"
msgstr ""

#: javascript.js:41
msgid "MSGID 7"
msgstr ""

#: javascript.js:42
msgid "MSGID 8"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript.js:43
msgid "MSGID 9"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript.js:44
msgctxt "MSGCTXT"
msgid "MSGID 10"
msgstr ""

#: javascript.js:45
msgctxt "MSGCTXT"
msgid "MSGID 11"
msgstr ""

#: javascript.js:46
msgctxt "MSGCTXT"
msgid "MSGID 12"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript.js:47
msgctxt "MSGCTXT"
msgid "MSGID 13"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""