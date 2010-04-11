#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 2);

my @data = (
    {
        test   => '11_extract_perl',
        path   => 'example',
        script => '-I../lib 11_extract_perl.pl cleanup',
        result => <<'EOT',
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=iso-8859-1\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: gettext.pl:23
msgid "This is a text."
msgstr ""

#: gettext.pl:26
msgid "{name} is programming {language}."
msgstr ""

#: gettext.pl:31
#: gettext.pl:36
msgid "Singular"
msgid_plural "Plural"
msgstr[0] ""

#: gettext.pl:41
#: gettext.pl:47
msgid "{num} shelf"
msgid_plural "{num} shelves"
msgstr[0] ""

#: gettext.pl:53
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: gettext.pl:57
msgctxt "maskulin"
msgid "Dear {name}"
msgstr ""

#: gettext.pl:62
#: gettext.pl:68
msgctxt "better"
msgid "shelf"
msgid_plural "shelves"
msgstr[0] ""

#: gettext.pl:74
#: gettext.pl:81
msgctxt "better"
msgid "{num} shelf"
msgid_plural "{num} shelves"
msgstr[0] ""

------------------------------------------------------------------------------
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=iso-8859-1\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: maketext.pl:23
msgid "This is a text."
msgstr ""

#: maketext.pl:26
msgid "[_1] is programming [_2]."
msgstr ""

#: maketext.pl:31
#: maketext.pl:35
msgid "[quant,_1,shelf,shelves]"
msgstr ""

#: maketext.pl:39
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: maketext.pl:43
msgctxt "maskulin"
msgid "Dear [_1]"
msgstr ""

#: maketext.pl:48
#: maketext.pl:53
msgctxt "better"
msgid "[*,_1,shelf,shelves]"
msgstr ""

#: maketext.pl:58
#: maketext.pl:62
#: maketext.pl:66
msgid "[*,_1,shelf,shelves,no shelf]"
msgstr ""

EOT
    },
    {
        test   => '13_extract_js',
        path   => 'example',
        script => '-I../lib 13_extract_js.pl cleanup',
        result => <<'EOT',
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

#: javascript.js:8
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

EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = qx{perl $data->{script} 2>&3};
    chdir($dir);
    eq_or_diff(
        $result,
        $data->{result},
        $data->{test},
    );
}