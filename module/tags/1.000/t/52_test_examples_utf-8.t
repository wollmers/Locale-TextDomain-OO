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

plan(tests => 6);

my @data = (
    {
        test => '04_lexicon_store_JSON_utf-8',
        path => 'example',
        script => '-I../lib -T 04_lexicon_store_JSON_utf-8.pl',
        result => <<'EOT',
Lexicon "en-gb:cat:dom" loaded from hash.
{"en-gb:cat:dom":{"{MSG_KEY_SEPARATOR}GBP":{"msgstr":"£"},"{MSG_KEY_SEPARATOR}":{"plural":"n","charset":"UTF-8","nplurals":1}},"i-default::":{"{MSG_KEY_SEPARATOR}":{"plural":"n != 1","nplurals":2}}}
EOT
    },
    {
        test   => '12_gettext_mo_utf-8',
        path   => 'example',
        script => '-I../lib -T 12_gettext_mo_utf-8.pl',
        result => <<'EOT',
Lexicon "de::" loaded from file "LocaleData/de/LC_MESSAGES/example.mo"
Lexicon "ru::" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo"
книга
1 книга
3 книги
5 книг
воссоединение
Это 1 воссоединение.
Это 3 воссоединения.
Эти 5 воссоединения.
EOT
    },
    {
        test   => '13_gettext_mo_cp1252',
        path   => 'example',
        script => '-I../lib -T 13_gettext_mo_cp1252.pl',
        result => <<'EOT',
Lexicon "de::" loaded from file "LocaleData/de/LC_MESSAGES/example_cp1252.mo"
Das sind deutsche Umlaute: ä ö ü ß Ä Ö Ü.
EOT
    },
    {
        test   => '16_multiplural_mo_utf-8',
        path   => 'example',
        script => '-I../lib -T 16_multiplural_mo_utf-8.pl',
        result => <<'EOT',
Lexicon "de:LC_MULTIPLURAL2:" loaded from file "LocaleData/de/LC_MULTIPLURAL2/example_multiplural.mo"
Dort ist nichts.
Dort ist 1 Regal.
Dort sind 2 Regale.
Dort sind 3 Regale.
Dort ist 1 Buch.
Dort ist 1 Buch und 1 Regal.
Dort ist 1 Buch und 2 Regale.
Dort ist 1 Buch und 3 Regale.
Dort sind 2 Bücher.
Dort sind 2 Bücher und 1 Regal.
Dort sind 2 Bücher und 2 Regale.
Dort sind 2 Bücher und 3 Regale.
EOT
    },
    {
        test   => '21_maketext_mo_utf-8',
        path   => 'example',
        script => '-I../lib -T 21_maketext_mo_utf-8.pl',
        result => <<'EOT',
Lexicon "de::" loaded from file "LocaleData/de/LC_MESSAGES/example_maketext.mo"
Das ist ein Text.
§ Buch
Steffen programmiert Perl.
1 Regal
2 Regale
Sehr geehrter
Sehr geehrter Steffen Winkler
Das ist/sind 1 Date.
Das ist/sind 2 Dates.
kein Regal
1 Regal
2 Regale
book
appointment
date
EOT
    },
    {
        test   => '23_localize_mo_utf-8',
        path   => 'example',
        script => '-I../lib -T 23_localize_mo_utf-8.pl',
        result => <<'EOT',
Lexicon "de::" loaded from file "LocaleData/de/LC_MESSAGES/example.mo"
Lexicon "ru::" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo"
книга
§ книга
воссоединение
book
appointment
date
EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = decode_utf8( qx{perl $data->{script} 2>&3} );
    chdir($dir);
    $result =~ tr{\\}{/};
    eq_or_diff(
        $result,
        $data->{result},
        $data->{test},
    );
}
