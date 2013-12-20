#!perl -T ## no critic (TidyCode)

use strict;
use warnings;

use Locale::TextDomain::OO;
use Locale::TextDomain::OO::Lexicon::File::MO;
use Locale::TextDomain::OO::TiedInterface;

our $VERSION = 0;

${$loc_ref} = Locale::TextDomain::OO->new(
    language => 'de',
    domain   => 'example',
    category => 'LC_MESSAGES',
    logger   => sub { () = print shift, "\n" },
    plugins  => [ qw(
        Expand::Gettext::DomainAndCategory
        Expand::Maketext
    ) ],
);

Locale::TextDomain::OO::Lexicon::File::MO
    ->new(
        logger => sub { () = print shift, "\n" },
    )
    ->lexicon_ref({
        search_dirs => [ './LocaleData' ],
        decode      => 1,
        data        => [
            '*:LC_MESSAGES:example'          => '*/LC_MESSAGES/example.mo',
            '*:LC_MESSAGES:example_maketext' => '*/LC_MESSAGES/example_maketext.mo',
        ],
    });

# only to output 1 line for an array reference
sub to_line {
    my $array_ref = shift;

    return join q{;}, @{$array_ref};
}

# run all translations
() = print map {"$_\n"}
    $__{'This is a text.'},
    $__->{'This is a text.'},
    $__{['This is a text.']},
    $__->{['This is a text.']},
    $__x{[
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ]},
    $__x->{[
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ]},
    $__n{[
        'Singular',
        'Plural',
        1,
    ]},
    $__n->{[
        'Singular',
        'Plural',
        2,
    ]},
    $__nx{[
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ]},
    $__nx->{[
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ]},
    $__p{[
        'maskulin',
        'Dear',
    ]},
    $__p->{[
        'maskulin',
        'Dear',
    ]},
    $__px{[
        'maskulin',
        'Dear {full name}',
        'full name' => 'Steffen Winkler',
    ]},
    $__px->{[
        'maskulin',
        'Dear {full name}',
        'full name' => 'Steffen Winkler',
    ]},
    $__np{[
        'appointment',
        'date',
        'dates',
        1,
    ]},
    $__np->{[
        'appointment',
        'date',
        'dates',
        2,
    ]},
    $__npx{[
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        1,
        num => 1,
    ]},
    $__npx->{[
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        2,
        num => 2,
    ]},
    to_line(
        $N__{'text'},
    ),
    to_line(
        $N__n{['singular', 'plural', 1]} ,
    ),
    ${$loc_ref}->domain,
    ${$loc_ref}->category;
() = $__begin_dc{[ qw( my_domain my_category ) ]};
() = print map {"$_\n"}
    ${$loc_ref}->domain,
    ${$loc_ref}->category,
    $__dcnpx{[
        'example',
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        3, ## no critic (MagicNumbers)
        'LC_MESSAGES',
        num => 3,
    ]},
    ${$loc_ref}->domain,
    ${$loc_ref}->category;
() = $__end_dc{[]};
() = print map {"$_\n"}
    ${$loc_ref}->domain,
    ${$loc_ref}->category;
() = $__begin_d{'example_maketext'};
() = print map {"$_\n"}
    ${$loc_ref}->domain,
    ${$loc_ref}->category,
    $maketext_p{[
        'appointment',
        'This is/are [*,_1,date,dates].',
        1,
    ]},
    to_line(
        $Nmaketext_p{[
            'appointment',
            'This is/are [*,_1,date,dates].',
            2,
        ]},
    ),
    ${$loc_ref}->domain,
    ${$loc_ref}->category;
() = $__end_d{[]};
() = print map {"$_\n"}
    ${$loc_ref}->domain,
    ${$loc_ref}->category;

# $Id$

__END__

Output:

Lexicon "de:LC_MESSAGES:example" loaded from file "LocaleData/de/LC_MESSAGES/example.mo"
Lexicon "ru:LC_MESSAGES:example" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo"
Lexicon "de:LC_MESSAGES:example_maketext" loaded from file "LocaleData/de/LC_MESSAGES/example_maketext.mo"
Das ist ein Text.
Das ist ein Text.
Das ist ein Text.
Das ist ein Text.
Steffen programmiert Perl.
Steffen programmiert Perl.
Einzahl
Mehrzahl
1 Regal
2 Regale
Sehr geehrter
Sehr geehrter
Sehr geehrter Steffen Winkler
Sehr geehrter Steffen Winkler
Date
Dates
Das ist 1 Date.
Das sind 2 Dates.
text
singular;plural;1
example
LC_MESSAGES
my_domain
my_category
Das sind 3 Dates.
my_domain
my_category
example
LC_MESSAGES
example_maketext
LC_MESSAGES
Das ist/sind 1 Date.
appointment;This is/are [*,_1,date,dates].;2
example_maketext
LC_MESSAGES
example
LC_MESSAGES
