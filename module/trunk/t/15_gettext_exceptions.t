#!perl -T

use strict;
use warnings;

use Test::More tests => 5;
use Test::NoWarnings;
use Test::Exception;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::Lexicon::Hash');
}

throws_ok
    sub {
        Locale::TextDomain::OO->new(
            xxx => 'xxx',
        );
    },
    qr{\A \QFound unknown attribute(s) passed to the constructor: xxx}xms,
    'unknown attribute';

X_WITHOUT_ARGS: {
    my $loc = Locale::TextDomain::OO->new(
        language => 'de',
        plugins  => [ qw( Expand::Gettext ) ],
    );
    Locale::TextDomain::OO::Lexicon::Hash
        ->new(
            logger => sub { note shift },
        )
        ->lexicon_ref({
            'de::' => [
                {
                    msgid  => "",
                    msgstr => ""
                        . "Content-Type: text/plain; charset=ISO-8859-1\n"
                        . "Plural-Forms: nplurals=2; plural=n != 1;\n",
                },
                {
                    # __x
                    msgid  => "{name} is programming {language}.",
                    msgstr => "{name} programmiert {language}.",
                },
            ],
        });
    is
        $loc->__x(
            '{name} is programming {language}.',
        ),
        '{name} programmiert {language}.',
        '__x without args';
}
