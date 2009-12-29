#!perl
#!perl -T

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_mach_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Test::More tests => 9 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::Perl');
    Locale::TextDomain::OO::Extract::Perl->init( qw(:plural) );
}

my $extractor;
lives_ok(
    sub {
        $extractor = Locale::TextDomain::OO::Extract::Perl->new();
    },
    'create extractor object',
);

{
    my $content = "1\n=pod\n3\n=cut\n5\n__END__\n7\n";
    $extractor->_get_preprocess_code->(\$content),
    eq_or_diff(
        $content,
        "1\n\n\n\n5\n",
        'check default preprocess',
    );
}

lives_ok(
    sub {
        open my $file, '<', './t/11_basics.t'
            or croak $OS_ERROR;
        $extractor->extract('11_basics', $file);
    },
    'open 11_basics.t and extract pot',
);

lives_ok(
    sub {
        open my $file, '<', '11_basics.pot'
            or croak $OS_ERROR;
        local $INPUT_RECORD_SEPARATOR = "__DATA__\n";
        (my $data = <DATA>) =~ s{__DATA__ .* \z}{}xms;
        eq_or_diff(
            <$file>,
            $data,
            'compare pot content',
        );
    },
    'read 11_basics.pot',
);

lives_ok(
    sub {
        open my $file, '<', './t/41_maketext_mo.t'
            or croak $OS_ERROR;
        $extractor->extract('41_maketext_mo', $file);
    },
    'open 41_maketext_mo.t and extract pot',
);

lives_ok(
    sub {
        open my $file, '<', '41_maketext_mo.pot'
            or croak $OS_ERROR;
        local $INPUT_RECORD_SEPARATOR = "__DATA__\n";
        (my $data = <DATA>) =~ s{__DATA__ .* \z}{}xms;
        eq_or_diff(
            <$file>,
            $data,
            'compare pot content',
        );
    },
    'read 41_maketext_mo.pot',
);

unlink qw(11_basics.pot 41_maketext_mo.pot);

__END__
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=iso-8859-1\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: 11_basics:34
msgid "This is a text."
msgstr ""

#: 11_basics:41
msgid "§ book"
msgstr ""

#: 11_basics:49
#: 11_basics:58
msgid "{name} is programming {language}."
msgstr ""

#: 11_basics:67
#: 11_basics:76
msgid "Singular"
msgid_plural "Plural"
msgstr[0] ""

#: 11_basics:86
#: 11_basics:96
msgid "{num} shelf"
msgid_plural "{num} shelves"
msgstr[0] ""

#: 11_basics:107
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: 11_basics:116
msgctxt "maskulin"
msgid "Dear {name}"
msgstr ""

#: 11_basics:126
#: 11_basics:136
msgctxt "better"
msgid "shelf"
msgid_plural "shelves"
msgstr[0] ""

#: 11_basics:147
#: 11_basics:158
msgctxt "better"
msgid "{num} shelf"
msgid_plural "{num} shelves"
msgstr[0] ""

__DATA__
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=iso-8859-1\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: 41_maketext_mo:34
msgid "This is a text."
msgstr ""

#: 41_maketext_mo:41
msgid "§ book"
msgstr ""

#: 41_maketext_mo:49
#: 41_maketext_mo:58
msgid "[_1] is programming [_2]."
msgstr ""

#: 41_maketext_mo:67
#: 41_maketext_mo:75
msgid "[quant,_1,shelf,shelves]"
msgstr ""

#: 41_maketext_mo:84
msgctxt "maskulin"
msgid "Dear"
msgstr ""

#: 41_maketext_mo:93
msgctxt "maskulin"
msgid "Dear [_1]"
msgstr ""

#: 41_maketext_mo:103
#: 41_maketext_mo:112
msgctxt "better"
msgid "[*,_1,shelf,shelves]"
msgstr ""

#: 41_maketext_mo:122
#: 41_maketext_mo:130
#: 41_maketext_mo:138
msgid "[*,_1,shelf,shelves,no shelf]"
msgstr ""

__DATA__
