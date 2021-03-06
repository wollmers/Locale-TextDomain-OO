#!perl -T ## no critic (TidyCode)

use strict;
use warnings;

use Locale::TextDomain::OO;
use Locale::TextDomain::OO::Lexicon::File::MO;
use Locale::TextDomain::OO::FunctionalInterface;

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

# run all translations
() = print map {"$_\n"}
    __('This is a text.'),
    __x(
        '{name} is programming {language}.',
        name     => 'Steffen',
        language => 'Perl',
    ),
    __n(
        'Singular',
        'Plural',
        1,
    ),
    __n(
        'Singular',
        'Plural',
        2,
    ),
    __nx(
        '{num} shelf',
        '{num} shelves',
        1,
        num => 1,
    ),
    __nx(
        '{num} shelf',
        '{num} shelves',
        2,
        num => 2,
    ),
    __p(
        'maskulin',
        'Dear',
    ),
    __px(
        'maskulin',
        'Dear {full name}',
        'full name' => 'Steffen Winkler',
    ),
    __np(
        'appointment',
        'date',
        'dates',
        1,
    ),
    __np(
        'appointment',
        'date',
        'dates',
        2,
    ),
    __npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        1,
        num => 1,
    ),
    __npx(
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        2,
        num => 2,
    ),
    N__('text'),
    N__n('singular', 'plural', 1),
    __begin_dc( qw( my_domain my_category ) ) && (),
    ${$loc_ref}->domain,
    ${$loc_ref}->category,
    __dcnpx(
        'example',
        'appointment',
        'This is {num} date.',
        'This are {num} dates.',
        3, ## no critic (MagicNumbers)
        'LC_MESSAGES',
        num => 3,
    ),
    ${$loc_ref}->domain,
    ${$loc_ref}->category,
    __end_dc && (),
    ${$loc_ref}->domain,
    ${$loc_ref}->category,
    __begin_d('example_maketext') && (),
    maketext_p(
        'appointment',
        'This is/are [*,_1,date,dates].',
        1,
    ),
    Nmaketext_p(
        'appointment',
        'This is/are [*,_1,date,dates].',
        2,
    ),
    __end_d && ();

# $Id$

__END__

Output:

Lexicon "de:LC_MESSAGES:example" loaded from file "LocaleData/de/LC_MESSAGES/example.mo".
Lexicon "ru:LC_MESSAGES:example" loaded from file "LocaleData/ru/LC_MESSAGES/example.mo".
Lexicon "de:LC_MESSAGES:example_maketext" loaded from file "LocaleData/de/LC_MESSAGES/example_maketext.mo".
Das ist ein Text.
Das ist 1 Date.
Das sind 2 Dates.
text
singular
plural
1
my_domain
my_category
Das sind 3 Dates.
my_domain
my_category
example
LC_MESSAGES
Das ist/sind 1 Date.
appointment
This is/are [*,_1,date,dates].
2
