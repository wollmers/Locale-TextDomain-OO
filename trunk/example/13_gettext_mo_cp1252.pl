#!perl -T

use strict;
use warnings;
use utf8;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
use Encode qw(encode decode);
require Locale::TextDomain::OO;

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('de');
my $text_domain = 'example_cp1252';
my $encoding    = 'cp1252';

my $loc = Locale::TextDomain::OO->new(
    text_domain  => $text_domain,
    search_dirs  => [qw(./LocaleData/)],
    # input filter
    input_filter => sub { encode($encoding, shift) },
    # output filter
    filter       => sub { decode($encoding, shift) },
);

# all unicode chars encode to UTF-8
binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

# run all translations
() = print map {"$_\n"}
    $loc->__(
        'This are German umlauts: ä ö ü ß Ä Ö Ü.',
    );

# $Id$

__END__

Output:

Das sind deutsche Umlaute: ä ö ü ß Ä Ö Ü.
