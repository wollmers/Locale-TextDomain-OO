#!perl -T

use strict;
use warnings;

use Test::More tests => 10;
use Test::NoWarnings;
use Test::Differences;
use JSON qw(decode_json);

BEGIN {
    require_ok('Locale::TextDomain::OO::Lexicon::Hash');
    require_ok('Locale::TextDomain::OO::Lexicon::StoreJSON');
}

Locale::TextDomain::OO::Lexicon::Hash
    ->new(
        logger => sub { note shift },
    )
    ->lexicon_ref({
        'en:cat1:dom1' => [
            {
                msgid  => "",
                msgstr => ""
                    . "Content-Type: text/plain; charset=UTF-8\n"
                    . "Plural-Forms: nplurals=1; plural=0;\n",
            },
        ],
        'de:cat1:dom1' => [
            {
                msgid  => "",
                msgstr => ""
                    . "Content-Type: text/plain; charset=UTF-8\n"
                    . "Plural-Forms: nplurals=1; plural=0;\n",
            },
        ],
        'en::dom1' => [
            {
                msgid  => "",
                msgstr => ""
                    . "Content-Type: text/plain; charset=UTF-8\n"
                    . "Plural-Forms: nplurals=1; plural=0;\n",
            },
        ],
        'en:cat1:' => [
            {
                msgid  => "",
                msgstr => ""
                    . "Content-Type: text/plain; charset=UTF-8\n"
                    . "Plural-Forms: nplurals=1; plural=0;\n",
            },
        ],
    });

eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON->new->to_json,
            )
        },
    ],
    [ qw(
        de:cat1:dom1
        en::dom1
        en:cat1:
        en:cat1:dom1
        i-default::
    ) ],
    'all categories and domains';

eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON
                    ->new(
                        filter_domain => [ qw( dom1 ) ],
                    )
                    ->to_json,
            )
        },
    ],
    [ qw(
        de:cat1:dom1
        en::dom1
        en:cat1:dom1
    ) ],
    'all categories, domain dom1';

eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON
                    ->new(
                        filter_category => [ qw( cat1 ) ],
                    )
                    ->to_json,
            )
        },
    ],
    [ qw(
        de:cat1:dom1
        en:cat1:
        en:cat1:dom1
    ) ],
    'category cat1, all domains';

eq_or_diff
    decode_json(
        Locale::TextDomain::OO::Lexicon::StoreJSON
            ->new(
                filter_domain_category => [ {} ],
            )
            ->to_json,
    ),
    {
        'i-default::' => {
            q{} => {
                nplurals => 2,
                plural   => 'n != 1',
            },
        },
    },
    'empty category and domain';

    eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON
                    ->new(
                        filter_domain_category => [ {
                            category => 'cat1',
                        } ],
                    )
                    ->to_json,
            )
        },
    ],
    [ qw(
        en:cat1:
    ) ],
    'category cat1, empty domain';

eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON
                    ->new(
                        filter_domain_category => [ {
                            domain => 'dom1',
                        } ],
                    )
                    ->to_json,
            )
        },
    ],
    [ qw(
        en::dom1
    ) ],
    'empty category, domain dom1';

eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON
                    ->new(
                        filter_domain_category => [ {
                            category => 'cat1',
                            domain   => 'dom1',
                        } ],
                    )
                    ->to_json,
            )
        },
    ],
    [ qw(
        de:cat1:dom1
        en:cat1:dom1
    ) ],
    'category cat1, domain dom1';
