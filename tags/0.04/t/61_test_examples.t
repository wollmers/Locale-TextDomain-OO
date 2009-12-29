#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 10);

my @data = (
    {
        test   => '11_gettext_mo',
        path   => 'example',
        script => '-I../lib -T 11_gettext_mo.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '14_N__',
        path   => 'example',
        script => '-I../lib -T 14_N__.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
Einzahl
1 Regal
Sehr geehrter Herr
Sehr geehrter Herr Winkler
gutes Regal
1 gutes Regal
EOT
    },
    {
        test   => '22_gettext_mo_functional_interface',
        path   => 'example',
        script => '-I../lib -T 22_gettext_mo_functional_interface.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '23_gettext_mo_tied_interface',
        path   => 'example',
        script => '-I../lib -T 23_gettext_mo_tied_interface.pl',
        result => <<'EOT',
Das ist ein Text.
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
EOT
    },
    {
        test   => '31_gettext_struct_from_locale_po',
        path   => 'example',
        script => '-I../lib -T 31_gettext_struct_from_locale_po.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '32_gettext_struct_from_dbd_po',
        path   => 'example',
        script => '-I../lib -T 32_gettext_struct_from_dbd_po.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '41_maketext_mo',
        path   => 'example',
        script => '-I../lib -T 41_maketext_mo.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
1 gutes Regal
2 gute Regale
0 Regale
1 Regal
2 Regale
EOT
    },
    {
        test   => '42_maketext_mo_style_gettext',
        path   => 'example',
        script => '-I../lib -T 42_maketext_mo_style_gettext.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
1 Regal
2 Regale
Sehr geehrter Herr
Sehr geehrter Herr Winkler
1 gutes Regal
2 gute Regale
0 Regale
1 Regal
2 Regale
EOT
    },
    {
        test   => '51_extract_perl',
        path   => 'example',
        script => '-I../lib 51_extract_perl.pl cleanup',
        result => <<'EOT',
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=iso-8859-1\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: 11_gettext_mo:23
msgid "This is a text."
msgstr ""

#: 11_gettext_mo:26
msgid "{name} is programming {language}."
msgstr ""

#: 11_gettext_mo:31
#: 11_gettext_mo:36
msgid "Singular"
msgid_plural "Plural"
msgstr[0] ""

#: 11_gettext_mo:41
#: 11_gettext_mo:47
msgid "{num} shelf"
msgid_plural "{num} shelves"
msgstr[0] ""

#: 11_gettext_mo:53
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: 11_gettext_mo:57
msgctxt "maskulin"
msgid "Dear {name}"
msgstr ""

#: 11_gettext_mo:62
#: 11_gettext_mo:68
msgctxt "better"
msgid "shelf"
msgid_plural "shelves"
msgstr[0] ""

#: 11_gettext_mo:74
#: 11_gettext_mo:81
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

#: 41_maketext_mo:23
msgid "This is a text."
msgstr ""

#: 41_maketext_mo:26
msgid "[_1] is programming [_2]."
msgstr ""

#: 41_maketext_mo:31
#: 41_maketext_mo:35
msgid "[quant,_1,shelf,shelves]"
msgstr ""

#: 41_maketext_mo:39
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: 41_maketext_mo:43
msgctxt "maskulin"
msgid "Dear [_1]"
msgstr ""

#: 41_maketext_mo:48
#: 41_maketext_mo:53
msgctxt "better"
msgid "[*,_1,shelf,shelves]"
msgstr ""

#: 41_maketext_mo:58
#: 41_maketext_mo:62
#: 41_maketext_mo:66
msgid "[*,_1,shelf,shelves,no shelf]"
msgstr ""

EOT
    },
    {
        test   => '53_extract_js',
        path   => 'example',
        script => '-I../lib 53_extract_js.pl cleanup',
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