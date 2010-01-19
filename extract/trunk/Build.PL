use strict;
use warnings;

use Module::Build;

my $is_ppm
    = (
        # install using ppm
        ! $ENV{AUTHOR_DIST}
        && eval 'require ActivePerl::PPM::Package'
    )
    || (
        # build ppm and ppd
        $ENV{AUTHOR_DIST}
        && $ENV{AUTHOR_DIST} eq 'ppm'
    );

Module::Build->new(
    module_name       => 'Locale::TextDomain::OO::Extract',
    license           => 'perl',
    dist_abstract     => 'Locale::TextDomain::OO::Extract - Extracts internationalization data as gettext pot file',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Locale/TextDomain/OO/Extract.pm',
    requires          => {
        perl                   => 5.006,
        version                => 0,
        parent                 => 0,
        Clone                  => 0,
        DBI                    => 0,
        'DBD::PO'              => 2.09,
        $is_ppm
        ? ()
        : (
            Carp                     => 0, # perl dist
            Cwd                      => 0, # perl dist
            Encode                   => 0, # perl dist
            English                  => 0, # perl dist
        )
    },
    build_requires => {
        'Test::NoWarnings'  => 0,
        'Test::Exception'   => 0,
        'Test::Differences' => 0,
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
