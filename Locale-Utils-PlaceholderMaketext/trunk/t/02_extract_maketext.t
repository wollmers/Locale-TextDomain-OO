use strict;
use warnings;
use utf8;

use Test::Most tests => 81;
use Test::NoWarnings;

BEGIN {
    require_ok('JEP::I18N::LocaleTextDomainOO');
    require_ok('Locale::TextDomain::OO::Lexicon::Hash');
}

Locale::TextDomain::OO::Lexicon::Hash->new->lexicon_ref({
    'de::' => [
        {
            msgid  => "",
            msgstr => ""
                . "Content-Type: text/plain; charset=utf-8\n"
                . "Plural-Forms: nplurals=2; plural=n != 1;\n",
        },
        {
            # maketext
            msgid  => "<§> Translation test",
            msgstr => "<§> Übersetzungstest (de)",
        },
        {
            # maketext
            msgid  => "<§> Translation test with ~[[_1]~] and ~[[_2]~]",
            msgstr => "<§> Übersetzungstest (de) mit ~[[_1]~] und ~[[_2]~]",
        },
        {
            # maketext_p
            msgctxt => 'ctxt',
            msgid   => "<§> Translation test",
            msgstr  => "<§> Übersetzungstest (p:de)",
        },
        {
            # maketext_p
            msgctxt => 'ctxt',
            msgid   => "<§> Translation test with ~[[_1]~] and ~[[_2]~]",
            msgstr  => "<§> Übersetzungstest (p:de) mit ~[[_1]~] und ~[[_2]~]",
        },
    ],
});

my $ltdoo = JEP::I18N::LocaleTextDomainOO->new;
$ltdoo->languages([ qw( de-de de en ) ]);

for ( qw( maketext loc localize ) ) {
    note 'real translation';
    my $method = $_;
    is
        $ltdoo->$method('<§> Translation test'),
        '<§> Übersetzungstest (de)',
        "$method de";
    is
        $ltdoo->$method('<§> Translation test with ~[[_1]~] and ~[[_2]~]' ),
        '<§> Übersetzungstest (de) mit [] und []',
        "$method de empty";
    is
        $ltdoo->$method('<§> Translation test with ~[[_1]~] and ~[[_2]~]', [] ),
        '<§> Übersetzungstest (de) mit [] und []',
        "$method de empty ref";
    is
        $ltdoo->$method('<§> Translation test with ~[[_1]~] and ~[[_2]~]', qw( 0 Ä ) ),
        '<§> Übersetzungstest (de) mit [0] und [Ä]',
        "$method de _1 _2";
    is
        $ltdoo->$method('<§> Translation test with ~[[_1]~] and ~[[_2]~]', [ qw( 0 Ä ) ] ),
        '<§> Übersetzungstest (de) mit [0] und [Ä]',
        "$method de _1 _2 ref";

    note 'real translation with context';
    $method = "${_}_p";
    is
        $ltdoo->$method('ctxt', '<§> Translation test'),
        '<§> Übersetzungstest (p:de)',
        "$method de";
    is
        $ltdoo->$method('ctxt', '<§> Translation test with ~[[_1]~] and ~[[_2]~]'),
        '<§> Übersetzungstest (p:de) mit [] und []',
        "$method de empty";
    is
        $ltdoo->$method('ctxt', '<§> Translation test with ~[[_1]~] and ~[[_2]~]', [] ),
        '<§> Übersetzungstest (p:de) mit [] und []',
        "$method de empty ref";
    is
        $ltdoo->$method('ctxt', '<§> Translation test with ~[[_1]~] and ~[[_2]~]', qw( 0 Ä ) ),
        '<§> Übersetzungstest (p:de) mit [0] und [Ä]',
        "$method de _1 _2";
    is
        $ltdoo->$method('ctxt', '<§> Translation test with ~[[_1]~] and ~[[_2]~]', [ qw( 0 Ä ) ] ),
        '<§> Übersetzungstest (p:de) mit [0] und [Ä]',
        "$method de _1 _2 ref";

    note 'extract only';
    $method = $_;
    is
        $ltdoo->$method('id ~[[_1]~]'),
        'id []',
        "$method missing empty";
    is
        $ltdoo->$method('id ~[[_1]~]', []),
        'id []',
        "$method missing empty ref";
    is
        $ltdoo->$method('id ~[[_1]~]', 2),
        'id [2]',
        "$method missing";
    is
        $ltdoo->$method('id ~[[_1]~]', [2]),
        'id [2]',
        "$method missing ref";

    note 'context';
    $method = "${_}_p";
    is
        $ltdoo->$method('ctxt', 'id ~[[_1]~]'),
        'id []',
        "$method missing empty";
    is
        $ltdoo->$method('ctxt', 'id ~[[_1]~]', []),
        'id []',
        "$method missing empty ref";
    is
        $ltdoo->$method('ctxt', 'id ~[[_1]~]', 2),
        'id [2]',
        "$method missing";
    is
        $ltdoo->$method('ctxt', 'id ~[[_1]~]', [2]),
        'id [2]',
        "$method missing ref";

    note 'N...';
    $method = "N${_}";
    eq_or_diff
        [ $ltdoo->$method('id ~[[_1]~]') ],
        [ 'id ~[[_1]~]' ],
        "method missing empty";
    eq_or_diff
        [ $ltdoo->$method('id ~[[_1]~]'), [] ],
        [ 'id ~[[_1]~]', [] ],
        "method missing empty ref";
    eq_or_diff
        [ $ltdoo->$method('id ~[[_1]~]', 2) ],
        [ 'id ~[[_1]~]', 2 ],
        "method missing";
    eq_or_diff
        [ $ltdoo->$method('id ~[[_1]~]', [2]) ],
        [ 'id ~[[_1]~]', [2] ],
        "$method missing ref";

    note 'N..._p';
    eq_or_diff
        [ $ltdoo->$method('ctxt', 'id ~[[_1]~]') ],
        [ 'ctxt', 'id ~[[_1]~]' ],
        "$method missing empty";
    eq_or_diff
        [ $ltdoo->$method('ctxt', 'id ~[[_1]~]', []) ],
        [ 'ctxt', 'id ~[[_1]~]', [] ],
        "$method missing empty ref";
    eq_or_diff
        [ $ltdoo->$method('ctxt', 'id ~[[_1]~]', 2) ],
        [ 'ctxt', 'id ~[[_1]~]', 2 ],
        "$method missing";
    eq_or_diff
        [ $ltdoo->$method('ctxt', 'id ~[[_1]~]', [2]) ],
        [ 'ctxt', 'id ~[[_1]~]', [2] ],
        "$method missing ref";
}
