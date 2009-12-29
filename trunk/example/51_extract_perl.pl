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
