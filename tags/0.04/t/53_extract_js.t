#!perl
#!perl -T

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_mach_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Test::More tests => 6 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::JavaScript');
    Locale::TextDomain::OO::Extract::JavaScript->init( qw(:plural) );
}

my $extractor;
lives_ok(
    sub {
        $extractor = Locale::TextDomain::OO::Extract::JavaScript->new(
            pot_charset => 'UTF-8',
        );
    },
    'create extractor object',
);

{
    my $content = "1\n//2\n3\n4/*\n5\n*/6\n";
    $extractor->_get_preprocess_code->(\$content),
    eq_or_diff(
        $content,
        "1\n\n3\n4\n\n6\n",
        'check default preprocess',
    );
}

lives_ok(
    sub {
        open my $file, '< :encoding(UTF-8)', './t/files_to_extract/javascript.js'
            or croak $OS_ERROR;
        $extractor->extract('javascript', $file);
    },
    'open javascript.js and extract pot',
);

lives_ok(
    sub {
        open my $file, '< :encoding(UTF-8)', 'javascript.pot'
            or croak $OS_ERROR;
        local $INPUT_RECORD_SEPARATOR = '__DATA__';
        (my $data = <DATA>) =~ s{__DATA__\z}{}xms;
        eq_or_diff(
            <$file>,
            $data,
            'compare pot content',
        );
    },
    'read pot file',
);

unlink 'javascript.pot';

__END__
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

__DATA__