#!perl

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);

use Locale::TextDomain::OO::Extract::Perl;
BEGIN {
    Locale::TextDomain::OO::Extract::Perl->init( qw(:plural) );
}

my $extractor = Locale::TextDomain::OO::Extract::Perl->new();

my $file_name = '11_gettext_mo.pl';
open my $file, '<', $file_name
    or croak "Can not open file $file_name\n$OS_ERROR";
$extractor->extract('11_gettext_mo', $file);

$file_name = '11_gettext_mo.pot';
open $file, '<', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
() = print {*STDOUT} <$file>;
() = close $file;

# $Id$

__END__