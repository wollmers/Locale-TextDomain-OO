#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

require Locale::TextDomain::OO::Extract;

my $domain_rule
    = my $text_rule
    = my $singular_rule
    = my $plural_rule
    = my $context_rule
    = [
        [
            qr{"}xms,
            qr{( (?: \\\\ \\\\ | \\\\ " | [^"] )+ )}xms,
            qr{"}xms,
        ],
        'OR',
        [
            qr{'}xms,
            qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
            qr{'}xms,
        ],
    ];
my $komma_rule = qr{\s* , \s*}xms;

my $rules = [
    [
        [
            [ qr{_ () \s* \( \s*}xms ],
            'OR',
            [ qr{\b (c?) gettext \( \s*}xms ],
        ],
        $text_rule,
    ],
    'OR',
    [
        qr{\b (d c?) gettext \s* \( \*}xms,
        $domain_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{\b (c? n) gettext \s* \( \s*}xms,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{\b (d c? n) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{\b (c? p) gettext \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{\b (d c? p) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $context_rule,
        $komma_rule,
        $text_rule,
    ],
    'OR',
    [
        qr{\b (c? n p) gettext \s* \( \s*}xms,
        $context_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
    'OR',
    [
        qr{\b (d c? n p) gettext \s* \( \s*}xms,
        $domain_rule,
        $komma_rule,
        $context_rule,
        $komma_rule,
        $singular_rule,
        $komma_rule,
        $plural_rule,
    ],
];

my $preprocess_code = sub {
    my $content_ref = shift;

    ${$content_ref} =~ s{// [^\n]* $}{}xmsg;
    ${$content_ref} =~ s{
        / \* (.*?) \* /
    }{
        join q{}, $1 =~ m{(\n)}xmsg;
    }xmsge;

    return;
};

my $parameter_mapping_code = sub {
    my $parameter = shift;

    my $extra_parameter = shift @{$parameter};
    if ( $extra_parameter =~ m{d}xms) {
         shift @{$parameter};
    }

    return {
        msgctxt      => $extra_parameter =~ m{p}xms
                        ? $extra_parameter
                        : undef,
        msgid        => scalar shift @{$parameter},
        msgid_plural => scalar shift @{$parameter},
    };
};

my $extractor = Locale::TextDomain::OO::Extract->new(
    preprocess_code        => $preprocess_code,
    pot_charset            => 'UTF-8',
    start_rule             => qr{(?: _ | d? c? n? p? gettext ) \s* \(}xms,
    rules                  => $rules,
    parameter_mapping_code => $parameter_mapping_code,
    is_debug => 1,
);

open my $file, '< :encoding(UTF-8)', './files_to_parse/javascript.js'
    or croak $OS_ERROR;
$extractor->extract('javascript', $file);

binmode STDOUT, 'encoding(UTF-8)'
    or croak "binmode STDOUT\n$OS_ERROR";

open $file, '< :encoding(UTF-8)', 'javascript.pot'
    or croak $OS_ERROR;
() = print {*STDOUT} <$file>;
() = close $file;

# $Id$

__END__