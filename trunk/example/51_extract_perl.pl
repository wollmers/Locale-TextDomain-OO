#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::Perl;
BEGIN {
    Locale::TextDomain::OO::Extract::Perl->init( qw(:plural) );
}

my $extractor = Locale::TextDomain::OO::Extract::Perl->new();

{
    my $file_name = '11_gettext_mo.pl';
    open my $file, '<', $file_name
        or croak "Can not open file $file_name\n$OS_ERROR";
    $extractor->extract('11_gettext_mo', $file);

    $file_name = '11_gettext_mo.pot';
    open $file, '<', $file_name
        or croak "Can not open $file_name\n$OS_ERROR";
    () = print {*STDOUT} <$file>;
    () = close $file;
}

() = print {*STDOUT} q{-} x 78, "\n"; ## no critic (MagicNumbers)

{
    my $file_name = '41_maketext_mo.pl';
    open my $file, '<', $file_name
        or croak "Can not open file $file_name\n$OS_ERROR";
    $extractor->extract('41_maketext_mo', $file);

    $file_name = '41_maketext_mo.pot';
    open $file, '<', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
    () = print {*STDOUT} <$file>;
    () = close $file;
}

# $Id$

__END__

Output:

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

------------------------------------------------------------------------------
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
