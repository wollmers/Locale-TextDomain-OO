#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::JavaScript;
BEGIN {
    Locale::TextDomain::OO::Extract::JavaScript->init( qw(:plural) );
}

my $extractor = Locale::TextDomain::OO::Extract::JavaScript->new(
    pot_charset => 'UTF-8',
);

my $file_name = './files_to_extract/javascript.js';
open my $file, '< :encoding(UTF-8)', $file_name ## no critic (BriefOpen)
    or croak "Can not open file $file_name\n$OS_ERROR";
$extractor->extract('javascript', $file);

binmode STDOUT, 'encoding(UTF-8)'
    or croak "Can not binmode STDOUT\n$OS_ERROR";

$file_name = 'javascript.pot';
open $file, '< :encoding(UTF-8)', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
() = print {*STDOUT} <$file>;
() = close $file;

# $Id$

__END__