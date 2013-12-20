#!perl

use strict;
use warnings;
use utf8;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{AUTHOR_TESTING} or plan(
    skip_all => 'Set $ENV{AUTHOR_TESTING} to run this test.'
);

plan(tests => 7);

my @data = (
    {
        test   => '02_filter',
        path   => 'example',
        script => '-I../lib -T 02_filter.pl',
        result => <<'EOT',
Using lexicon "i-default::". msgstr not found for msgctxt=undef, msgid="Hello World 1!".
Using lexicon "i-default::". msgstr not found for msgctxt=undef, msgid="Hello World 2!".
Hello World 1! filter added: i-default
Hello World 2! filter added: i-default
EOT
    },
    {
        test   => '03_language_of_languages',
        path   => 'example',
        script => '-I../lib -T 03_language_of_languages.pl',
        result => <<'EOT',
i-default
Lexicon "de::" loaded from hash.
Language "de" selected.
de
EOT
    },
    {
        test   => '11_gettext_hash',
        path   => 'example',
        script => '-I../lib -T 11_gettext_hash.pl',
        result => <<'EOT',
Das ist ein Text.
Steffen programmiert Perl.
Steffen programmiert {language}.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter
Sehr geehrter Steffen Winkler
Date
Dates
Das ist 1 Date.
Das sind 2 Dates.
EOT
    },
    {
        test   => '14_gettext_N',
        path   => 'example',
        script => '-I../lib -T 14_gettext_N.pl',
        result => <<'EOT',
__: This is a text.
__x: Steffen is programming Perl.
__n: Singular
__nx: 1 shelf
__p: Dear
__px: Dear Steffen Winkler
__np: date
__npx: 1 date
EOT
    },
    {
        test   => '22_loc_mo_style_gettext',
        path   => 'example',
        script => '-I../lib -T 22_loc_mo_style_gettext.pl',
        result => <<'EOT',
Lexicon "de:LC_MESSAGES:example_maketext_style_gettext" loaded from file "LocaleData/de/LC_MESSAGES/example_maketext_style_gettext.mo"
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
        test   => '41_tied_interface',
        path   => 'example',
        script => '-I../lib -T 41_tied_interface.pl',
        result => <<'EOT',
Lexicon "de:LC_MESSAGES:example" loaded from file "LocaleData/de/LC_MESSAGES/example.mo"
Lexicon "ru:LC_MESSAGES:example" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo"
Lexicon "de:LC_MESSAGES:example_maketext" loaded from file "LocaleData/de/LC_MESSAGES/example_maketext.mo"
Das ist ein Text.
Das ist ein Text.
Das ist ein Text.
Das ist ein Text.
Steffen programmiert Perl.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter
Sehr geehrter
Sehr geehrter Steffen Winkler
Sehr geehrter Steffen Winkler
Date
Dates
Das ist 1 Date.
Das sind 2 Dates.
text
singular;plural;1
example
LC_MESSAGES
my_domain
my_category
Das sind 3 Dates.
my_domain
my_category
example
LC_MESSAGES
example_maketext
LC_MESSAGES
Das ist/sind 1 Date.
appointment;This is/are [*,_1,date,dates].;2
example_maketext
LC_MESSAGES
example
LC_MESSAGES
EOT
    },
    {
        test   => '42_functional_interface',
        path   => 'example',
        script => '-I../lib -T 42_functional_interface.pl',
        result => <<'EOT',
Lexicon "de:LC_MESSAGES:example" loaded from file "LocaleData/de/LC_MESSAGES/example.mo"
Lexicon "ru:LC_MESSAGES:example" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo"
Lexicon "de:LC_MESSAGES:example_maketext" loaded from file "LocaleData/de/LC_MESSAGES/example_maketext.mo"
Das ist ein Text.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter
Sehr geehrter Steffen Winkler
Date
Dates
Das ist 1 Date.
Das sind 2 Dates.
text
singular
plural
1
my_domain
my_category
Das sind 3 Dates.
my_domain
my_category
example
LC_MESSAGES
Das ist/sind 1 Date.
appointment
This is/are [*,_1,date,dates].
2
EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = qx{perl $data->{script} 2>&3};
    chdir($dir);
    $result =~ tr{\\}{/};
    eq_or_diff(
        $result,
        $data->{result},
        $data->{test},
    );
}
