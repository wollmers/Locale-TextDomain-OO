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
    $extractor->_set_content_ref(\$content);
    $extractor->preprocess(),
    eq_or_diff(
       $content,
        "1\n\n\n\n5\n",
        'check default preprocess',
    );
}

lives_ok(
    sub {
        open my $file_handle, '<', './t/files_to_extract/gettext.pl'
            or croak $OS_ERROR;
        $extractor->extract({
            file_name   => 'gettext',
            file_handle => $file_handle,
        });
    },
    'open gettext.pl and extract pot',
);

lives_ok(
    sub {
        open my $file_handle, '<', 'gettext.pot'
            or croak $OS_ERROR;
        local $INPUT_RECORD_SEPARATOR = "__DATA__\n";
        (my $data = <DATA>) =~ s{__DATA__ .* \z}{}xms;
        eq_or_diff(
            <$file_handle>,
            $data,
            'compare pot content',
        );
    },
    'read gettext.pot',
);

lives_ok(
    sub {
        open my $file_handle, '<', './t/files_to_extract/maketext.pl'
            or croak $OS_ERROR;
        $extractor->extract({
            file_name   => 'maketext',
            file_handle => $file_handle,
        });
    },
    'open maketext.pl and extract pot',
);

lives_ok(
    sub {
        open my $file_handle, '<', 'maketext.pot'
            or croak $OS_ERROR;
        local $INPUT_RECORD_SEPARATOR = "__DATA__\r\n";
        (my $data = <DATA>) =~ s{__DATA__ .* \z}{}xms;
        eq_or_diff(
            <$file_handle>,
            $data,
            'compare pot content',
        );
    },
    'read maketext.pot',
);

unlink qw(gettext.pot maketext.pot);

__END__
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

__DATA__
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

__DATA__