package Locale::TextDomain::OO;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp qw(croak);
use Cwd qw(abs_path);
use English qw(-no_match_vars $EVAL_ERROR);
use I18N::LangTags::Detect;
use I18N::LangTags qw(implicate_supers panic_languages);
require Safe;

sub new {
    my ($class, %init) = @_;

    my $self = bless {}, $class;

    # Set an object that implements gettext ...
    (
        defined $init{gettext_object}
        && $init{gettext_object}->can('dngettext')
    )
    ? $self->_set_object(delete $init{gettext_object})
    # ... or the implementation class of gettext.
    : $self->_set_gettext_package(
        defined $init{gettext_package}
        ? delete $init{gettext_package}
        : 'Locale::Messages'
    );

    # Search dirs are given or use the defaults
    $self->_set_search_dirs(
        ( ref $init{search_dirs} eq 'ARRAY' )
        ? delete $init{search_dirs}
        : $self->_get_default_search_dirs()
    );

    # The text domain is a non empty string.
    # The default text domain is the package name of the caller.
    $self->_set_text_domain(
        ( defined $init{text_domain} && length $init{text_domain} )
        ? delete $init{text_domain}
        : caller
    );

    my $keys = join ', ', keys %init;
    if ($keys) {
        croak "Unknown parameter: $keys";
    }

    return $self;
}

sub _set_gettext_package {
    my ($self, $gettext_package) = @_;

    my $code = "require $gettext_package";
    () = eval $code; ## no critic (StringyEval)
    $EVAL_ERROR
        and croak "$code\n$EVAL_ERROR";
    $self->{sub} = {
        map { ## no critic (ComplexMappings)
            my $code_ref = $gettext_package->can($_);
            $code_ref
            ? ( $_ => $code_ref )
            : ();
        } qw(bindtextdomain dgettext dngettext dpgettext dnpgettext)
    };

    return $self;
}

sub _get_sub {
    my ($self, $name) = @_;

    return $self->{sub}->{$name};
}

sub _get_object {
    my $self = shift;

    return $self->{object};
}

sub _set_object {
    my ($self, $object) = @_;

    $self->{object} = $object;

    return $self;
}

sub _get_default_search_dirs {
    my $self = shift;

    return [
        map {
            -d "$_/LocaleData"
            ? "$_/LocaleData"
            : ();
        } (
            @INC,
            qw(/usr/share/locale /usr/local/share/locale),
        )
    ];
}

sub _get_search_dirs {
    my $self = shift;

    return $self->{search_dirs};
}

sub _set_search_dirs {
    my ($self, $search_dirs) = @_;

    $self->{search_dirs} = $search_dirs;

    return $self;
}

sub _get_text_domain {
    my $self = shift;

    return $self->{text_domain};
}

sub get_file_path {
    my ($self, $text_domain, $suffix) = @_;

    my @languages_want = I18N::LangTags::Detect::detect();
    my @languages_all  = implicate_supers(@languages_want);
    push @languages_all, panic_languages(@languages_all);
    my @search_dirs = map {
        abs_path $_;
    } @{ $self->_get_search_dirs() };
    for my $language (@languages_all) {
        for my $dir (@search_dirs) {
            my $file = "$dir/$language/LC_MESSAGES/$text_domain$suffix";
            if (-f $file || -l $file) {
                return
                    wantarray
                    ? ($dir, $language, 'LC_MESSAGES')
                    : "$dir/$language/LC_MESSAGES";
            }
        }
    }

    return;
}

sub _set_text_domain {
    my ($self, $text_domain) = @_;

    $self->{text_domain} = $text_domain;
    $self->_get_sub('bindtextdomain')
        or return $self;

    my ($dir, $language) = $self->get_file_path($text_domain, '.mo');
    defined $dir
        or return $self;

    local $ENV{LANGUAGE} = $language;
    $self->_get_sub('bindtextdomain')->($text_domain => $dir);

    return $self;
}

my $perlify_plural_forms = sub {
    my $plural_forms_ref = shift;

    defined ${$plural_forms_ref}
        or croak 'Plural-Forms are not defined';
    ${$plural_forms_ref} =~ s{\b ( nplurals | plural | n ) \b}{\$$1}xmsg;

    return;
};

sub get_nplurals {
    my (undef, $plural_forms) = @_;

    $perlify_plural_forms->(\$plural_forms);
    my $code = <<"EOC";
        my \$n = 0;
        my (\$nplurals, \$plural);
        $plural_forms
        \$nplurals;
EOC
    my $nplurals = Safe->new()->reval($code)
        or croak "Code of Plural-Forms $plural_forms is not safe, $EVAL_ERROR";

    return $nplurals;
}

sub get_function_ref_plural {
    my (undef, $plural_forms) = @_;

    $perlify_plural_forms->(\$plural_forms);
    my $code = <<"EOC";
        sub {
            my \$n = shift;

            my (\$nplurals, \$plural);
            $plural_forms

            return \$plural;
        }
EOC
    my $code_ref = Safe->new()->reval($code)
        or croak "Code $plural_forms is not safe, $EVAL_ERROR";

    return $code_ref;
}

sub _expand {
    my (undef, $translation, %args) = @_;

    my $regex = join q{|}, map { quotemeta $_ } keys %args;
    $translation =~ s{
        \{ ($regex) \}
    }{
        defined $args{$1} ? $args{$1} : "{$1}"
    }xmsge;

    return $translation;
}

sub __x {
    my ($self, $msgid, %args) = @_;

    my $object = $self->_get_object();
    my $translation
        = $object
        ? $object->dgettext(
            $self->_get_text_domain(),
            $msgid,
        )
        : $self->_get_sub('dgettext')->(
            $self->_get_text_domain(),
            $msgid,
        );

    return
        %args
        ? $translation = $self->_expand(
            $translation,
            %args,
        )
        : $translation;
}

sub __nx {
    my ($self, $msgid, $msgid_plural, $count, %args) = @_;

    my $object = $self->_get_object();
    my $translation
        = $object
        ? $object->dngettext(
            $self->_get_text_domain(),
            $msgid,
            $msgid_plural,
            $count,
        )
        : $self->_get_sub('dngettext')->(
            $self->_get_text_domain(),
            $msgid,
            $msgid_plural,
            $count,
        );

    return
        %args
        ? $translation = $self->_expand(
            $translation,
            %args,
        )
        : $translation;
}

sub __px {
    my ($self, $msgctxt, $msgid, %args) = @_;

    my $object = $self->_get_object();
    my $translation
        = $object
        ? $object->dpgettext(
            $self->_get_text_domain(),
            $msgctxt,
            $msgid,
        )
        : $self->_get_sub('dpgettext')->(
            $self->_get_text_domain(),
            $msgctxt,
            $msgid,
        );

    return
        %args
        ? $translation = $self->_expand(
            $translation,
            %args,
        )
        : $translation;
}

sub __npx { ## no critic (ManyArgs)
    my ($self, $msgctxt, $msgid, $msgid_plural, $count, %args) = @_;

    my $object = $self->_get_object();
    my $translation
        = $object
        ? $object->dnpgettext(
            $self->_get_text_domain(),
            $msgctxt,
            $msgid,
            $msgid_plural,
            $count,
        )
        : $self->_get_sub('dnpgettext')->(
            $self->_get_text_domain(),
            $msgctxt,
            $msgid,
            $msgid_plural,
            $count,
        );

    return
        %args
        ? $translation = $self->_expand(
            $translation,
            %args,
        )
        : $translation;
}

BEGIN {
    no warnings qw(redefine); ## no critic (NoWarnings)
    *__   = \&__x;
    *__n  = \&__nx;
    *__p  = \&__px;
    *__np = \&__npx;

    # Dummy methods for string marking.
    my $dummy = sub {
        my (undef, @more) = @_;
        return join q{,}, map {defined $_ ? $_ : 'undef'} @more;
    };
    *N__    = $dummy;
    *N__x   = $dummy;
    *N__n   = $dummy;
    *N__nx  = $dummy;
    *N__p   = $dummy;
    *N__px  = $dummy;
    *N__np  = $dummy;
    *N__npx = $dummy;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO - Perl OO Interface to Uniforum Message Translation

$Id$

$HeadURL$

=head1 VERSION

0.01

=head1 DESCRIPTION

This module provides a high-level interface to Perl message translation.

=head2 Why a new module?

This module is nearly the same like L<Locale::TextDomain>.
But this module has an object oriented interface.

Locale::TextDomain depends on L<Locale::Messages>
and Locale::Messages depends on gettext mo-files.
This is a very good idea to do this.
It is a standard.

But if the data are not saved in mo-files
and the project is not a new project,
how to bind a database or anything else
to the Locale::TextDomain API?

It runs - now!
Do not follow the dead end of L<Locale::Maketext>.
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

=item *

The plural form is allowed after a number, followed by a whitespace,
but not before a number.

=item *

There is no plural form without a nummber in the phrase.

=item *

Placeholders are numbered serially.
It is difficult to translate this,
because the sense of the phrase could be lost.

=item *

But there are a lot of modules around Locale::Maketext.

=back

This is the reason for a new module to have:

=over

=item *

Endless (real: up to 6) plural forms
controlled by the translater and not by the developer.

=item *

Named placeholders.

=item *

L<Locale::TextDomain::OO> can bind gettext subroutines
or gettext methods.

An example for binding subroutines is the default Locale::Messages.

An example for object binding is L<Locale::Messages::OO::Struct>.

=back

=head2 What is the difference?

As default this module calls the subroutines of module Locale::Messages.

This behaviour is changeable.
Choose a functional or object oriented module.
Locale::Messages is an functional module.
Locale::Messages::OO::Struct is an object oriented module.

Locale::Messages::OO::Struct implements the idea
to read the full data into a data structure
for fast access.

=head2 More informations

Read the documentation of L<Locale::TextDoamin>
to learn more about the translation subroutines.

Run the examples of this distribution.

=head2 Overview

      Application calls     Application calls     Application calls
      TextDomain methods    TextDomain methods     method maketext
          (the goal)       and Maketext methods    (the beginning)
              |              (the changeover)            |
              |                      |                   |
              |                      v                   v
              |            .----------------------------------.
              |            |          Interface like          |
              |            |     Locale::Maketext::Simple     |
              |            |               and (!)            |
              |            |      Locale::TextDomain::OO      |
              |            |----------------------------------|
              |            | Locale::TextDomain::OO::Maketext |
              |            `----------------------------------'
              |                |
              v                v
          .------------------------.
          |     Interface like     |
          |   Locale::TextDomain   |
          |------------------------|
          | Locale::TextDomain::OO |
          `------------------------'
              |                |
              v                v
 .------------------.    .--------------------------------.
 | Locale::Messages |    | Locale::TextDomain::OO::Struct |
 |  (the default)   |    |        (a possibility)         |
 `------------------'    `--------------------------------'
           |                               |
           |                               v
           |                     .-------------------.
           |                     |    Datastruct     |
           |                     |-------------------|
           |                     |  |                |
           |                     |  +--[text domain] |
           |                     |     |             |
           |                     |     `--[...]      |
           |                     `-------------------'
           |                       ^               ^
           |                       |               |
           |   .------------------------.          |
           |   |       build using      |   .-------------.
           |   |   po extrction tools   |   | build using |
           |   |      like DBD::PO      |   |     DBI     |
           |   | or DBD::PO::Locale::PO |   `-------------'
           |   `------------------------'          ^
           |                ^                      |
           v                |                 _____|_____
    .----------.      .----------.           /_ _ _ _ _ _\
    | mo-files |-.    | po-files |-.         |           |
    `----------' |    `----------' |         | Database  |
      `----------'      `----------'         `-----------'
           ^                ^                      ^
           |                |                      |
      build using      build using            existing data
     gettext tools    gettext tools

=head1 SYNOPSIS

    require Locale::TextDomain::OO;

=head1 SUBROUTINES/METHODS

=head2 method new

The text domain is __PACKAGE__.

    my $loc = Locale::TextDoamin::OO->new();

or

    my $loc = Locale::TextDoamin::OO->new(
        text_domain => __PACKAGE__,
        ...
    );

Note the text domain.

    my $loc = Locale::TextDoamin::OO->new(
        text_domain => 'my-package',
        ...
    );

Note the search dirs.

    my $loc = Locale::TextDoamin::OO->new(
        local_dirs => \@local_dirs,
        ...
    );

Note, that the default of gettest_package is L<Locale::Messages>.
This package have to implement the subroutines
'dgettext', 'dngettext', 'dpgettext', 'dnpgettext'
and can implement the subroutine 'bindtextdomain'.

    my $loc = Locale::TextDoamin::OO->new(
        gettext_package => 'Locale::Messages::AnyObject',
        text_domain     => 'example',
        local_dirs      => \@local_dirs,
    );

Or the package have to implement the methods
'dgettext', 'dngettext', 'dpgettext', 'dnpgettext'.

    my $loc = Locale::TextDoamin::OO->new(
        gettext_object => Locale::Messages::OO::Struct->new(\my %struct),
        text_domain     => 'example',
        local_dirs      => \@local_dirs,
    );

=head2 method get_file_path

    my $file_suffix = '.foo';
    my $file_path   = $loc->get_file_path($text_domain, $file_suffix);

If a file based database system not exists,
create an extra file system.
Write down for which language and which text domain a database exists.
Instead of an "$text_domain$suffix" database file
create some empty dummy files.

If possible, extract this informations automaticly from the database.

Than the method get_file_path checks the wanted languages
and matches the existing langauges.
Read L<I18N::LangTags>, panic_languages for more informations.

    my ($dir, $language) = $loc->get_file_path($text_domain, $file_suffix);

Another way to use this module with a none file based database system
is to implement the language selection self.

=head2 object or class method get_nplurals

How many plurals has the translation?
This is one-time interesting to read the translation data.

    $nplurals = $self->get_nplurals(
        'nplurals=2; plural=n != 1;' # look at po-/mo-file header
    );

or

    $nplurals = Locale::Text::Domain::OO->get_nplurals(
        'nplurals=2; plural=n != 1;' # look at po-/mo-file header
    );

=head2 object or class method get_function_ref_plural

Which plural form sould be used?
The code runs during every plural tranlation.

    $code_ref = $self->get_function_ref_plural(
        'nplurals=2; plural=n != 1;' # look at po-/mo-file header
    );

or

    $code_ref = Locale::Text::Domain::OO->get_function_ref_plural(
        'nplurals=2; plural=n != 1;' # look at po-/mo-file header
    );

=head2 Translating methods

How to bild the method name?

Use __ and append this with 'n', 'p' and/or 'x' in alphabetic order.

 .----------------------------------------------------------------.
 | Snippet | Description                                          |
 |---------+------------------------------------------------------|
 | __      | Special marked for extraction.                       |
 | x       | Last parameters are the hash for named placeholders. |
 | n       | Using plural forms.                                  |
 | p       | Context is the first parameter.                      |
 '----------------------------------------------------------------'

=head3 __ Translate only

    print $loc->__(
        'Hello World!',
    );

=head3 __x Named placeholders

    print $loc->__x(
        'Hello {name}!',
        name => 'Steffen',
    );

=head3 __n Plural

    print $loc->__n(
        'one file read',
        'a lot of files read',
        $num_files,
    );

=head3 __nx Plural and named placeholders

    print $loc->__nx(
        'one file read',
        '{num} files read',
        $num_files,
        num => $num_files,
    );

The sub __xn is the same like sub __nx
at Locale::TextDomain.

Method __xn is not implemented
because it is the same like method __nx.

=head3 __p Context

    print $loc->__p (
        'time',
        'to',
    );

    print $loc->__p (
        'destination',
        'to',
    );

=head3 __px Context and named placeholders

    print $loc->__px (
        'destination',
        'from {town_from} to {town_to}',
        town_from => 'Chemnitz',
        town_to   => 'Erlangen',
    );

=head3 __np Context and plural

    print $loc->__np (
        'maskulin',
        'Dear friend',
        'Dear friends',
        $friends,
    );

=head3 __npx Context, plural and named placeholders

    print $loc->__npx(
        'maskulin',
        'Mr. {name} has {num} book.',
        'Mr. {name} has {num} books.',
        $books,
        name => $name,
    );


=head2 Methods to mark the translation for extraction only

How to bild the method name?

Use N__ and append this with 'n', 'p' and/or 'x' in alphabetic order.

 .----------------------------------------------------------------.
 | Snippet | Description                                          |
 |---------+------------------------------------------------------|
 | N__     | Special marked for extraction.                       |
 | x       | Last parameters are the hash for named placeholders. |
 | n       | Using plural forms.                                  |
 | p       | Context is the first parameter.                      |
 '----------------------------------------------------------------'

=head3 N__, N__x, N__n, N__nx, N__p, N__px, N__np, N__npx

The extractor is looking for C<__('...'>
and has no problem with C<$loc->N__('...')>.

This is the idea of the N-Methods.

    $loc->N__('...');

or

    Locale::Text::Domain::OO->N__('...');

=head1 EXAMPLE

Inside of this Distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error message in case of unknown parameters.

 Unknown parameter: ...

Error message at calculation plural forms.

 Plural-Forms are not defined

 Code of Plural-Forms ... is not safe, ...

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

Carp

Cwd

English

L<I18N::LangTags::Detect>

L<I18N::LangTags>

Safe

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin>

L<Locale::Messages>

L<http://www.gnu.org/software/gettext/manual/gettext.html>

L<http://en.wikipedia.org/wiki/Gettext>

L<http://translate.sourceforge.net/wiki/l10n/pluralforms>

L<http://rassie.org/archives/247> The choice of the right module for the translation.

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut