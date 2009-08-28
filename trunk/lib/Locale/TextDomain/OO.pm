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

    # Set the implementation class of gettext
    $self->_set_gettext_package(
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
    my @languages_all = implicate_supers(@languages_want);
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

sub get_function_ref_plural {
    my ($self, $plural_forms) = @_;

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

sub get_function_ref_nplurals {
    my ($self, $plural_forms) = @_;

    $perlify_plural_forms->(\$plural_forms);
    my $code = <<"EOC";
        sub {
            my \$n = 0;
            my (\$nplurals, \$plural);
            $plural_forms

            return \$nplurals;
        }
EOC
    my $code_ref = Safe->new()->reval($code)
        or croak "Code of Plural-Forms $plural_forms is not safe, $EVAL_ERROR";

    return $code_ref;
}

sub _expand {
    my ($self, $translation, %args) = @_;

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

    return $self->_expand(
        $self->_get_sub('dgettext')->(
            $self->_get_text_domain(),
            $msgid,
        ),
        %args,
    );
}

sub __nx {
    my ($self, $msgid, $msgid_plural, $count, %args) = @_;

    return $self->_expand(
        $self->_get_sub('dngettext')->(
            $self->_get_text_domain(),
            $msgid,
            $msgid_plural,
            $count,
        ),
        %args,
    );
}

sub __px {
    my ($self, $msgctxt, $msgid, %args) = @_;

    return $self->_expand(
        $self->_get_sub('dpgettext')->(
            $self->_get_text_domain(),
            $msgctxt,
            $msgid,
        ),
        %args,
    );
}

sub __npx { ## no critic (ManyArgs)
    my ($self, $msgctxt, $msgid, $msgid_plural, $count, %args) = @_;

    return $self->_expand(
        $self->_get_sub('dnpgettext')->(
            $self->_get_text_domain(),
            $msgctxt,
            $msgid,
            $msgid_plural,
            $count,
        ),
        %args
    );
}

BEGIN {
    no warnings qw(redefine); ## no critic (NoWarnings)
    *__   = \&__x;
    *__n  = \&__nx;
    *__p  = \&__px;
    *__np = \&__npx;
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

The module Locale::TextDomain::OO provides a high-level interface
to Perl message translation.

=head2 Why a new module?

Locale::TextDomain::OO is nearly the same like L<Locale::TextDomain>.
But this module has an object oriented interface.

L<Locale::TextDomain> depends on L<Locale::Messages>
and L<Locale::Messages> depends on gettext mo-files.

But if the data are not saved in mo-files
and the project is not a new project,
how can I bind a database or anything else to the Locale::TextDomain API?

I can - now!
And I must not follow the dead end of L<Locale::Maketext>:

 * Locale::Maketext allows 2 plural forms (plus zero) only.
   The developer has to control this.
   'quant' is the death of automatic translation.
 * The plural form is allowed after (not before)
   a number and a whitespace.
 * There is no plural form without a nummber in the phrase.
 * Placeholders are numbered serially.
   It is difficult to translate this
   because the sense of the phrase will be lost.

This is the reason for a new module to have:

 * endless (real: up to 4) plural forms
   controlled by the translater and not by the developer.
 * Named placeholders.
 * Locale::Messages::AnyObject is a less bounded gettext interface
   for gettext without mo-files.

=head2 What is the difference?

As default this module calls the subroutines of module L<Locale::Messages>.

You can change this behaviour.

L<Locale::Messages::AnyObject> maps the subroutine calls back to object calls
and allows to write your own object-oriented modules.
L<Locale::Messages::Struct> ist such one.
The idea is to read the database information into a data structure
for fast access.

=head2 Read more!

Read the documentation of L<Locale::TextDoamin>
for more informations.

=head1 SYNOPSIS

    use Locale::TextDomain::OO;

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

Note that the default of gettest_package is 'Locale::Messages'.
This package have to implement the subroutines
'dgettext', 'dngettext', 'dpgettext', 'dnpgettext'
and can implement the subroutine 'bindtextdomain'.

    my $loc = Locale::TextDoamin::OO->new(
        gettext_package => 'Locale::Messages::AnyObject',
        text_domain     => 'example',
        local_dirs      => \@local_dirs,
    );

=head2 method get_file_path

    my $file_suffix = '.foo';
    my $file_path = $loc->get_file_path($text_domain, $file_suffix);

If a file based database system not exists create an extra file system!
Write down for wich language and wich text domain a database exists.
Insted of an "$text_domain$suffix" database file emty dummy files.
Maybe extract this informations automaticly from the database.
Than the get_file_path method checks the wanted languages
and matches the existing langauges.
Read L<I18N::LangTags>, panic_languages for more informations.

    my ($dir, $language) = $loc->get_file_path($text_domain, $file_suffix);

Another way to use this module with a none file based database system
is to implement the language selection by yourself.

=head2 method get_function_ref_plural

How many plurals has the translation?

    $code_ref = $self, get_function_ref_plural(
        'nplurals=2; plural=n != 1;' # look at in po-/mo-file header
    );

=head2 method get_function_ref_nplurals

Wich plural form sould be used?

    $code_ref = $self->get_function_ref_nplurals(
        'nplurals=2; plural=n != 1;' # look at in po-/mo-file header
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

L<http://www.gnu.org/software/gettext/manual/gettext.html>

L<http://en.wikipedia.org/wiki/Gettext>

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