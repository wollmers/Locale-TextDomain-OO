#!perl -T

use strict;
use warnings;
use utf8;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
use Encode qw(encode_utf8 decode_utf8);
require Locale::TextDomain;
use Locale::Messages qw(bind_textdomain_filter);

local $ENV{LANGUAGE} = 'ru';
my $text_domain      = 'example';

# bind text domain
Locale::TextDomain->import( $text_domain, qw(./LocaleData) );

# bind output_filter
bind_textdomain_filter($text_domain, \&decode_utf8);

# all unicode chars encode to UTF-8
binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

# run all translations
() = print map {"$_\n"}
    __(
        'book',
    ),
    __(
        encode_utf8('§ book'),
    ),
    __n(
        encode_utf8('§§ book'),
        encode_utf8('§§ books'),
        0,
    ),
    __n(
        encode_utf8('§§ book'),
        encode_utf8('§§ books'),
        1,
    ),
    __n(
        encode_utf8('§§ book'),
        encode_utf8('§§ books'),
        2,
    ),
    __p(
        'c',
        'c book',
    ),
    __p(
        encode_utf8('c§'),
        encode_utf8('c§ book'),
    );

# $Id$

__END__

Output:

книга
§ книга
§§ книг
§§ книга
§§ книги
c книга
c§ книга
