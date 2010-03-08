#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::JavaScript;
BEGIN {
    Locale::TextDomain::OO::Extract::JavaScript->init( qw(:plural) );
}

my $extractor = Locale::TextDomain::OO::Extract::JavaScript->new(
    pot_charset => 'UTF-8',
);

my $file_name = './files_to_extract/javascript.js';
open my $file, '< :encoding(UTF-8)', $file_name ## no critic (BriefOpen)
    or croak "Can not open file $file_name\n$OS_ERROR";
$extractor->extract('javascript', $file);

binmode STDOUT, 'encoding(UTF-8)'
    or croak "Can not binmode STDOUT\n$OS_ERROR";

$file_name = 'javascript.pot';
open $file, '< :encoding(UTF-8)', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
() = print {*STDOUT} <$file>;
() = close $file;

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

#: javascript:3
#: javascript:4
#: javascript:5
msgid "some string"
msgstr ""

#: javascript:6
msgid "this will get translated"
msgstr ""

#: javascript:7
msgid "text"
msgstr ""

#: javascript:8
msgid ""
"Hello World!\n"
""
msgstr ""

#: javascript:9
msgid "Hello %1"
msgstr ""

#: javascript:10
msgid "This is the %1 %2"
msgstr ""

#: javascript:11
#: javascript:15
msgid ""
"One file deleted.\n"
""
msgid_plural ""
"%d files deleted.\n"
""
msgstr[0] ""

#: javascript:19
msgctxt "Verb: To View"
msgid "View"
msgstr ""

#: javascript:20
msgctxt "Noun: A View"
msgid "View"
msgstr ""

#: javascript:22
msgid "one banana"
msgid_plural "%1 bananas"
msgstr[0] ""

#: javascript:35
msgid "MSGID 1"
msgstr ""

#: javascript:36
msgid "MSGID 2"
msgstr ""

#: javascript:37
msgid "MSGID 3"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript:38
msgctxt "MSGCTXT"
msgid "MSGID 4"
msgstr ""

#: javascript:39
msgctxt "MSGCTXT"
msgid "MSGID 5"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript:40
msgid "MSGID 6"
msgstr ""

#: javascript:41
msgid "MSGID 7"
msgstr ""

#: javascript:42
msgid "MSGID 8"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript:43
msgid "MSGID 9"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript:44
msgctxt "MSGCTXT"
msgid "MSGID 10"
msgstr ""

#: javascript:45
msgctxt "MSGCTXT"
msgid "MSGID 11"
msgstr ""

#: javascript:46
msgctxt "MSGCTXT"
msgid "MSGID 12"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""

#: javascript:47
msgctxt "MSGCTXT"
msgid "MSGID 13"
msgid_plural "MSGID_PLURAL"
msgstr[0] ""
