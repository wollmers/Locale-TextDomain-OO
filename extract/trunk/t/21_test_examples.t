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

#: gettext:23
msgid "This is a text."
msgstr ""

#: gettext:26
msgid "{name} is programming {language}."
msgstr ""

#: gettext:31
#: gettext:36
msgid "Singular"
msgid_plural "Plural"
msgstr[0] ""

#: gettext:41
#: gettext:47
msgid "{num} shelf"
msgid_plural "{num} shelves"
msgstr[0] ""

#: gettext:53
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: gettext:57
msgctxt "maskulin"
msgid "Dear {name}"
msgstr ""

#: gettext:62
#: gettext:68
msgctxt "better"
msgid "shelf"
msgid_plural "shelves"
msgstr[0] ""

#: gettext:74
#: gettext:81
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

#: maketext:23
msgid "This is a text."
msgstr ""

#: maketext:26
msgid "[_1] is programming [_2]."
msgstr ""

#: maketext:31
#: maketext:35
msgid "[quant,_1,shelf,shelves]"
msgstr ""

#: maketext:39
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: maketext:43
msgctxt "maskulin"
msgid "Dear [_1]"
msgstr ""

#: maketext:48
#: maketext:53
msgctxt "better"
msgid "[*,_1,shelf,shelves]"
msgstr ""

#: maketext:58
#: maketext:62
#: maketext:66
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
"Hello World!\\n"
""
msgstr ""

#: javascript:9
msgid "Hello %1"
msgstr ""

#: javascript:10
msgid "This is the %1 %2"
msgstr ""

#: javascript:11
msgid ""
"One file deleted.\\n"
""
msgid_plural ""
"%d files deleted.\\n"
""
msgstr[0] ""

#: javascript:15
msgid ""
"One file deleted.\\n"
""
msgid_plural ""
"%d files deleted.\\n"
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