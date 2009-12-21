#!perl

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_mach_vars $OS_ERROR);

require Locale::TextDomain::OO::Extract;

my $extractor = Locale::TextDomain::OO::Extract->new(
    preprocess_ref => sub { return },
    start_rule => qr{\[ \% \s* l() \(}xms,
    rules      => [
        qr{\[ \% \s* l() \(}xms,
        qr{\s*}xms,
        [
            qr{'}xms,
            qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
            qr{'}xms,
            'RETURN',
        ],
    ],
    pot_charset => 'UTF-8',
);

open my $file, '< :encoding(UTF-8)', './files_to_parse/tt.tt'
    or croak $OS_ERROR;
$extractor->extract('tt', $file);

open $file, '< :encoding(UTF-8)', 'tt.pot'
    or croak $OS_ERROR;
() = print {*STDOUT} <$file>;
() = close $file;

# $Id$

__END__

