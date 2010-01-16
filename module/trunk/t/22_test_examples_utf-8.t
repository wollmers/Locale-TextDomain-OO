#!perl

use strict;
use warnings;
use utf8;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);
use Encode qw(decode_utf8);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 5);

my @data = (
#    {
#        test   => '01_locale_textdomian_utf-8',
#        path   => 'example',
#        script => '-I../lib -T 01_locale_textdomian_utf-8.pl',
#        result => <<'EOT',
#книга
#§ книга
#§§ книг
#§§ книга
#§§ книги
#c книга
#c§ книга
#EOT
#    },
    {
        text   => '12_gettext_mo_utf-8',
        path   => 'example',
        script => '-I../lib -T 12_gettext_mo_utf-8.pl',
        result => <<'EOT',
книга
§ книга
EOT
    },
    {
        text   => '13_gettext_mo_cp1252',
        path   => 'example',
        script => '-I../lib -T 13_gettext_mo_cp1252.pl',
        result => <<'EOT',
Das sind deutsche Umlaute: ä ö ü ß Ä Ö Ü.
EOT
    },
    {
        test   => '33_gettext_struct_from_locale_po_utf-8',
        path   => 'example',
        script => '-I../lib -T 33_gettext_struct_from_locale_po_utf-8.pl',
        result => <<'EOT',
книга
§ книга
§§ книг
§§ книга
§§ книги
c книга
c§ книга
EOT
    },
    {
        test   => '34_gettext_struct_from_dbd_po_utf-8',
        path   => 'example',
        script => '-I../lib -T 34_gettext_struct_from_dbd_po_utf-8.pl',
        result => <<'EOT',
книга
§ книга
§§ книг
§§ книга
§§ книги
c книга
c§ книга
EOT
    },
    {
        test   => '52_extract_tt',
        path   => 'example',
        script => '-I../lib 52_extract_tt.pl cleanup',
        result => <<'EOT',
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

EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = decode_utf8 qx{perl $data->{script} 2>&3};
    chdir($dir);
    eq_or_diff(
        $result,
        $data->{result},
        $data->{test},
    );
}
