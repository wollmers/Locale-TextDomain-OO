package Locale::TextDomain::OO; ## no critic (TidyCode)

use strict;
use warnings;

our $VERSION = '1.004';

use Locale::TextDomain::OO::Translator;

sub new {
    my ($class, @args) = @_;

    return Locale::TextDomain::OO::Translator->new(
        Locale::TextDomain::OO::Translator->load_plugins(@args),
    );
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO - Perl OO Interface to Uniforum Message Translation

$Id$

$HeadURL$

=head1 VERSION

1.004

Starting with version 1.000 the interface has changed.

=head1 DESCRIPTION

This module provides a high-level interface to Perl message translation.

=head2 Why a new module?

This module is similar
to L<Locale::TextDomain|Locale::TextDomain>
and L<Locale::Maketext|Locale::Maketext>.

This module is not using/changing any system locale
like L<Locale::TextDomain|Locale::TextDomain>.

This module has no magic in how to get the language
like L<Locale::Maketext|Locale::Maketext>.
You decide what you need.

There are some plugins, so it is possible
to use the maketext and/or getext style.

Locale::TextDomain::OO has a flexible object oriented interface
based on L<Moo|Moo>.

Creating the Lexicon and translating are two splitted things.
So it is possible to create the lexicon during the initialisation phase.
The connection between both is the singleton mechanimsm of the lexicon module.

=head2 How to extract?

Use module Locale::TextDomain::OO::Extract.
This is a base class for all source scanner to create pot files.
Use this base class and give this module the rules
or use one of the already exteded classes.
Locale::TextDomain::OO::Extract::Perl is a extension for Perl code and so on.

=head2 Do not follow the dead end of Locale::Maketext!

What is the problem of?

=over

=item *

Locale::Maketext allows 2 plural forms (and zero) only.
This is changable,
but the developer has to control the plural forms.
He is not an omniscient translator.

=item *

'quant' inside a phrase is the end of the automatic translation
because quant is an 'or'-construct.

    begin of phrase [quant,_1,singular,plural,zero] end of phrase

=item *

The plural form is allowed after a number,
followed by a whitespace,
not a non-breaking whitespace.

    1 book
    2 books

A plural form can not be before a number.

    It is 1 book.
    These are 2 books.

=item *

There is no plural form without a number in the phrase.

    I like this book.
    I like these books.

=item *

Placeholders are numbered serially.
It is difficult to translate this
because the sense of the phrase could be lost.

    [_1] is a [_2] in [_3].

    Erlangen is a town in Bavaria.

=item *

But there are lots of modules around Locale::Maketext.

=back

This is the reason for another module to have:

=over

=item *

Endless (real: up to 6) plural forms
controlled by the translater and not by the developer.

=item *

Named placeholders.

=back

=head2 More informations

Run the examples of this distribution (folder example).

=head2 Overview

 Application calls   Application calls   Application calls
 gettext methods     getext and          maketext methods
         |           maketext methods            |
         |                         |             |
         v                         v             v
 .-----------------------------------------------------------.
 | Locale::TextDomain::OO                                    |
 | with plugin LanguageOfLanguages                           |
 | with plugins Locale::TextDomain::OO::Plugin::Expand::...  |
 |-----------------------------------------------------------|
 | Gettext                    |\       /| Maketext           |
 | Gettext::DomainAndCategory | > and < | Maketext::Loc      |
 |                            |/       \| Maketext::Localize |
 `-----------------------------------------------------------'
                            ^
                            |
 .--------------------------'-------------------.
 | Locale::Text::Domain::OO::Singleton::Lexicon |----------------------.
 `----------------------------------------------'                      |
                            ^                                          |
                            |                                          |
 .--------------------------'-------------------------------.          |
 | build lexicon using Locale::TextDomain::OO::Lexicon::... |          |
 |----------------------------------------------------------|          |
 |           Hash              |   File::MO     | File::PO  |          |
 `----------------------------------------------------------'          |
       ^               ^               ^              ^                |
       |               |               |              |                |
 .-----'-----.    _____|_____    .-----'----.       .-----'----.       |
 | Perl      |   /_ _ _ _ _ _\   | mo files |-.     | po files |-.     |
 | data      |   |           |   `----------' |-.   `----------' |-.   |
 | structure |   | Database  |     `----------' |     `----------' |   |
 `-----------'   `-----------'       `----------'       `----------'   |
                                       ^                   ^           |
                                       |                   |           |
                                  build using        build using       |
                                  gettext tools      gettext tools     |
                                                 (not yet implemented) |
                              .----------------------------------------'
                              |
                              v
 .------------------------------------------------------------------.
 | build JSON lexicon using Locale::TextDomain::OO::Lexicon::ToJSON |
 `------------------------------------------------------------------'
                              |
                              v
                      .--------------.
                      | lexicon.json |
                      `-------.------'
                              |
                              v
 .--- not yet implemented --------.
 | js/loc.js                      |
 | with plugins js/loc/expand/... |
 |--------------------------------|
 | gettext.js                     |
 | gettext/domain_and_category.js |
 | maketext.js                    |
 | maketext/loc.js                |
 | maketext/localize.js           |
 `--------------------------------'

=head1 SYNOPSIS

    require Locale::TextDomain::OO;
    my $loc = Locale::TextDomain::OO->new(
        # all parameters are optional
        plugins  => [ qw(
            Expand::Gettext
            +My::Special::Plugin
        ) ],
        language => 'de',          # default is i-default
        category => 'LC_MESSAGES', # default is q{}
        domain   => 'MyDomain',    # default is q{}
        filter   => sub {
            my ($self, $translation_ref) = @_;
            # encode if needed
            # run a formatter if needed, e.g.
            ${$translation_ref} =~ s{__ ( .+? ) __}{<b>$1</b>}xmsg;
            return $self;
        },
    );

This configuration would be use Lexicon "de:LC_MESSAGES:MyDomain".
That lexicon should be filled with data.

=head1 SUBROUTINES/METHODS

=head2 method new

see SYNOPSIS

=head2 method language

Set the language an prepare the translation.
You know exactly how to set.
This module is stupid.

    $loc->language( $language );

Get back

    $language = $loc->language;

=head2 method category

You are able to ignore or set the category.
That depends on your project.

    $loc->category($category || q{} );
    $category = $loc->category;

=head2 method domain

You are able to ignore or set the domain.
That depends on your project.

    $loc->domain($domain || q{} );
    $domain = $loc->domain;

=head2 method filter

You are allowed to run code after each translation.

    $loc->filter( sub {
        my ( $self, $translation_ref ) = @_;

        # $self is $loc
        # manipulate ${$translation_ref}
        # do not undef ${$translation_ref}

        return $self;
    } );

Switch off the filter

    $loc->filter(undef);

=head2 method translate

Do never call that method in your project.
This method was called from expand plugins only.

    $translation
        = $self->translate($msgctxt, $msgid, $msgid_plural, $count, $is_n);

=head2 method run_filter

Do never call that method in your project.
This method was called from expand plugins only.

    $self->filter(\$translation);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Read the file README there.
Then run the *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Locale::TextDomain::OO::Translator|Locale::TextDomain::OO::Translator>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

In the gettext manual you can read at
"15.5.18.9 Bugs, Pitfalls, And Things That Do Not Work"
something that is not working with Perl.
The examples there are rewritten and explained here.

=head2 string interpolation and joined strings

    print <<"EOF";
        $loc->__(
            'The dot operator'
            . ' does not work'
            . ' here!'
        )
        Likewise, you cannot @{[ $loc->__('interpolate function calls') ]}
        inside quoted strings or quote-like expressions.
    EOF

The fist call can not work.
Methods are not callable in interpolated strings/"here documents".
The . operator is normally not implemented at the extractor.
The first parameter of method __ must be a constant.

There is no problem for the second call because the extractor
extracts the Perl file as text and did not parse the code.

=head2 Regex eval

This example is no problem here, because the file is extracted as text.

    s/<!--START_OF_WEEK-->/$loc->__('Sunday')/e;

=head2 named placeholders

Method __ is an alias for method __x.
But {OPTIONS} is not a placeholder
because key "OPTIONS" is not in parameters.

    die $loc->__("usage: $0 {OPTIONS} FILENAME...\n");

    die $loc->__x("usage: {program} {OPTIONS} FILENAME...\n", program => $0);

=head1 SEE ALSO

L<Locale::TextDoamin|Locale::TextDoamin>

L<Locale::Maketext|Locale::Maketext>

L<http://www.gnu.org/software/gettext/manual/gettext.html>

L<http://en.wikipedia.org/wiki/Gettext>

L<http://translate.sourceforge.net/wiki/l10n/pluralforms>

L<http://rassie.org/archives/247>
The choice of the right module for the translation.

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 - 2013,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
