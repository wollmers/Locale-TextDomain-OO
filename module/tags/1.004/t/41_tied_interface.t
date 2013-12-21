#!perl -T

use strict;
use warnings;

use Test::More tests => 27;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

BEGIN {
    require_ok('Locale::TextDomain::OO');
    require_ok('Locale::TextDomain::OO::Lexicon::File::MO');
    require_ok('Locale::TextDomain::OO::TiedInterface');
    Locale::TextDomain::OO::TiedInterface->import;
}

throws_ok
    sub {
        Locale::TextDomain::OO::TiedInterface->import(undef);
    },
    qr{\A \QAn undefined value is not a variable name}xms,
    'tie object method with an undefined method name';
throws_ok
    sub {
        Locale::TextDomain::OO::TiedInterface->import('__');
    },
    qr{\A \Q"__" is not a hash or a hash reference}xms,
    'tie __ failed';
throws_ok
    sub {
        Locale::TextDomain::OO::TiedInterface->import('$__y');
    },
    qr{\A "\$__y"\Q is not exported}xms,
    'tie $__y failed';

${$loc_ref} = Locale::TextDomain::OO->new(
    language => 'de',
    domain   => 'test',
    category => 'LC_MESSAGES',
    logger   => sub { note shift },
    plugins  => [ qw(
        Expand::Gettext::DomainAndCategory
        Expand::Maketext
    ) ],
);

Locale::TextDomain::OO::Lexicon::File::MO
    ->new(
        logger => sub { note shift },
    )
    ->lexicon_ref({
        search_dirs => [ './t/LocaleData' ],
        decode      => 1,
        data        => [
            '*:LC_MESSAGES:test'          => '*/LC_MESSAGES/test.mo',
            '*:LC_MESSAGES:test_maketext' => '*/LC_MESSAGES/test_maketext.mo',
        ],
    });

# gettext
is
    $__{'This is a text.'},
    'Das ist ein Text.',
    '%__';
is
    $__->{'This is a text.'},
    'Das ist ein Text.',
    '$__';
is
    $__{['This is a text.']},
    'Das ist ein Text.',
    '%__ []';
is
    $__->{['This is a text.']},
    'Das ist ein Text.',
    '$__ []';
is
    $__npx{[
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        1,
        num => 1,
    ]},
    'Das ist 1 Date.',
    '%__npx 1';
is
    $__npx->{[
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        2,
        num => 2,
    ]},
    'Das sind 2 Dates.',
    '$__npx 2';
eq_or_diff
    $N__{'text'},
    'text',
    '%N__ scalar';
eq_or_diff
    $N__{['text']},
    'text',
    '%N__ arrayref';
eq_or_diff
    $N__->{'text'},
    'text',
    '$N__';
eq_or_diff
    $N__n{['singular', 'plural', 1]},
    [ qw( singular plural 1 ) ],
    '%N__n';
eq_or_diff
    $N__n{['singular', 'plural', 2]},
    [ qw( singular plural 2 ) ],
    '$N__';
() = $__begin_dc{[ qw( my_domain my_category ) ]};
is
    ${$loc_ref}->domain,
    'my_domain',
    '%__begin_dc domain';
is
    ${$loc_ref}->category,
    'my_category',
    '%__begin_dc category';
is
    $__dcnpx{[
        'test',
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        3,
        'LC_MESSAGES',
        num => 3,
    ]},
    'Das sind 3 Dates.',
    '%__dcnpx 3';
is
    ${$loc_ref}->domain,
    'my_domain',
    '%__begin_dc domain unchanged';
is
    ${$loc_ref}->category,
    'my_category',
    '%__begin_dc category unchanged';
() = $__end_dc{[]};
is
    ${$loc_ref}->domain,
    'test',
    '%__end_dc domain';
is
    ${$loc_ref}->category,
    'LC_MESSAGES',
    '%__end_dc category';

# maketext
() = $__begin_d->{test_maketext};
is
    $maketext_p{[
        'appointment',
        'This is/are [*,_1,date,dates].',
        1,
    ]},
    'Das ist/sind 1 Date.',
    '%maketext_p';
eq_or_diff
    $Nmaketext_p->{[
        'appointment',
        'This is/are [*,_1,date,dates].',
        2,
    ]},
    [
        'appointment',
        'This is/are [*,_1,date,dates].',
        2,
    ],
    '$Nmaketext_p';
() = $__end_d->{[]};
