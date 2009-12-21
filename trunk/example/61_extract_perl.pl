#!perl -T

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_mach_vars $OS_ERROR);

require Locale::TextDomain::OO::Extract;

my $extractor = Locale::TextDomain::OO::Extract->new();

my $file_name = '11_gettext_mo.pl';
open my $file, '<', $file_name
    or croak "Can not open file $file_name\n$OS_ERROR";
$extractor->extract('11_gettext_mo', $file);

$file_name = '11_gettext_mo.pot';
open $file, '<', $file_name
    or croak "Can not open $file_name\n$OS_ERROR";
() = print {*STDOUT} <$file>;
() = close $file;
