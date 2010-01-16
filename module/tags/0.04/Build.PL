use strict;
use warnings;

use Module::Build;

my $is_ppm = eval 'require ActivePerl::PPM::Package';

Module::Build->new(
    module_name       => 'Locale::TextDomain::OO',
    license           => 'perl',
    dist_abstract     => 'Locale::TextDomain::OO - Perl OO Interface to Uniforum Message Translation',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Locale/TextDomain/OO.pm',
    requires          => {
        perl                   => 5.006,
        version                => 0,
        parent                 => 0,
        Safe                   => 0,
        Clone                  => 0, # for extractor only
        DBI                    => 0, # for extractor only
        'DBD::PO'              => 2.09,
        'Perl6::Export::Attrs' => 0,
        'I18N::LangTags'       => 0,
        'Tie::Sub'             => 0.09,
        $is_ppm
        ? (
            'libintl-perl' => 1.20,
        )
        : (
            Carp                     => 0, # perl dist
            Cwd                      => 0, # perl dist
            Encode                   => 0, # perl dist
            English                  => 0, # perl dist
            'I18N::LangTags::Detect' => 0, # dist I18N-LangTags
            'Locale::Messages'       => 1.20, # dist libintl-perl
        )
    },
    build_requires => {
        'Test::NoWarnings'  => 0,
        'Test::Exception'   => 0,
        'Test::Differences' => 0,
        'Data::Dumper'      => 0,
        $is_ppm
        ? (
            'Test::Simple' => 0,
        )
        : (
            'Test::More'          => 0, # dist Test-Simple
            'DBD::PO::Locale::PO' => 0, # dist DBD::PO
        )
    },
    recommends => {
        # build
        'Test::Pod'              => '1.14',
        'Test::Pod::Coverage'    => '1.04',
    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL *.po *.txt
    ) ],
)->create_build_script();