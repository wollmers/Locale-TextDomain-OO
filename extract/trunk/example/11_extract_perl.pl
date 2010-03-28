#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::Perl;

my $extractor = Locale::TextDomain::OO::Extract::Perl->new();

{
    my $file_name = './files_to_extract/gettext.pl';
    open my $file_handle, '<', $file_name ## no critic (BriefOpen)
        or croak "Can not open file $file_name\n$OS_ERROR";
    $extractor->extract({
        file_name   => 'gettext',
        file_handle => $file_handle,
    });

    $file_name = 'gettext.pot';
    open $file_handle, '<', $file_name
        or croak "Can not open $file_name\n$OS_ERROR";
    () = print {*STDOUT} <$file_handle>;
    () = close $file_handle;
}

() = print {*STDOUT} q{-} x 78, "\n"; ## no critic (MagicNumbers)

{
    my $file_name = './files_to_extract/maketext.pl';
    open my $file_handle, '<', $file_name ## no critic (BriefOpen)
        or croak "Can not open file $file_name\n$OS_ERROR";
    $extractor->extract({
        file_name   => 'maketext',
        file_handle => $file_handle,
    });

    $file_name = 'maketext.pot';
    open $file_handle, '<', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
    () = print {*STDOUT} <$file_handle>;
    () = close $file_handle;
}

# only for automatic test of example
if ($ARGV[0] && $ARGV[0] eq 'cleanup') {
    unlink qw(gettext.pot maketext.pot);
}

# $Id: 11_extract_perl.pl 291 2010-01-17 10:44:30Z steffenw $

__END__

Output:

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