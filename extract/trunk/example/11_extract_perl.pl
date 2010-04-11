#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::Perl;

my $extractor = Locale::TextDomain::OO::Extract::Perl->new();

{
    my $filename = './files_to_extract/gettext.pl';
    open my $filehandle, '<', $filename ## no critic (BriefOpen)
        or croak "Can not open file $filename\n$OS_ERROR";
    $extractor->extract({
        source_filename      => 'gettext.pl',
        source_filehandle    => $filehandle,
        destination_filename => 'gettext.pot',
    });

    $filename = 'gettext.pot';
    open $filehandle, '<', $filename
        or croak "Can not open $filename\n$OS_ERROR";
    () = print {*STDOUT} <$filehandle>;
    () = close $filehandle;
}

() = print {*STDOUT} q{-} x 78, "\n"; ## no critic (MagicNumbers)

{
    my $filename = './files_to_extract/maketext.pl';
    open my $filehandle, '<', $filename ## no critic (BriefOpen)
        or croak "Can not open file $filename\n$OS_ERROR";
    $extractor->extract({
        source_filename      => 'maketext.pl',
        source_filehandle    => $filehandle,
        destination_filename => 'maketext.pot',
    });

    $filename = 'maketext.pot';
    open $filehandle, '<', $filename
    or croak "Can not open $filename\n$OS_ERROR";
    () = print {*STDOUT} <$filehandle>;
    () = close $filehandle;
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
#: maketext:35
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