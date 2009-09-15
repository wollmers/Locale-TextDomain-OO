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
my $text_domain      = 'test';

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
    );

# $Id$

__END__

Output:

книга
§ книга
