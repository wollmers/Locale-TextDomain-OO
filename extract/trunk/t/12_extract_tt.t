#!perl
#!perl -T

use strict;
use warnings;
use utf8;

use Carp qw(croak);
use English qw(-no_mach_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    use_ok('Locale::TextDomain::OO::Extract::TT');
}

my $extractor;
lives_ok(
    sub {
        $extractor = Locale::TextDomain::OO::Extract::TT->new(
            po_charset => 'UTF-8',
        );
    },
    'create extractor object',
);

lives_ok(
    sub {
        open my $filehandle, '< :encoding(UTF-8)', './t/files_to_extract/template.tt'
            or croak $OS_ERROR;
        $extractor->extract({
            source_filename      => 'template',
            source_filehandle    => $filehandle,
            destination_filename => 'dest_template.pot'
        });
    },
    'open template.tt and extract pot',
);

lives_ok(
    sub {
        open my $file_handle, '< :encoding(UTF-8)', 'dest_template.pot'
            or croak $OS_ERROR;
        local $INPUT_RECORD_SEPARATOR = '__DATA__';
        (my $data = <DATA>) =~ s{__DATA__\z}{}xms;
        eq_or_diff(
            <$file_handle>,
            $data,
            'compare pot content',
        );
    },
    'read dest_template.pot',
);

unlink 'dest_template.pot';

__END__
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=n != 1;"

#: template:9
msgid "Text Ä"
msgstr ""

#: template:13
msgid "Text Ö"
msgstr ""

#: template:16
msgid "Text Ü"
msgstr ""

__DATA__