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

unlink '11_basics.pot';

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
msgctxt "p"
msgid "maskulin"
msgid_plural "Dear"
msgstr[0] ""

#: 11_basics:116
msgctxt "px"
msgid "maskulin"
msgid_plural "Dear {name}"
msgstr[0] ""

#: 11_basics:126
#: 11_basics:136
msgctxt "np"
msgid "better"
msgid_plural "shelf"
msgstr[0] ""

#: 11_basics:147
#: 11_basics:158
msgctxt "npx"
msgid "better"
msgid_plural "{num} shelf"
msgstr[0] ""

__DATA__
111