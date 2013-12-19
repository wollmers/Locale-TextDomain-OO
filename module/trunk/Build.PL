use strict;
use warnings;

use Module::Build;

Module::Build->new(
    module_name       => 'Locale::TextDomain::OO',
    license           => 'perl',
    dist_abstract     => 'Locale::TextDomain::OO - Perl OO Interface to Uniforum Message Translation',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Locale/TextDomain/OO.pm',
    requires          => {
        'perl'                               => 5.006,
        'charnames'                          => 0,
        'namespace::autoclean'               => 0,
        'Carp'                               => 0,
        'Encode'                             => 0,
        'English'                            => 0,
        'File::Spec'                         => 0,
        'JSON'                               => 0,
        'List::MoreUtils'                    => 0,
        'Locale::MO::File'                   => 0,
        'Locale::Utils::PlaceholderMaketext' => 0,
        'Locale::Utils::PlaceholderNamed'    => 0,
        'Moo'                                => 0,
        'Moo::Role'                          => 0,
        'MooX::StrictConstructor'            => 0,
        'MooX::Types::MooseLike::Base'       => 0,
        'Path::Class'                        => 0,
        'Path::Class::Rule'                  => 0,
        'Safe'                               => 0,
        'Tie::Sub'                           => '0.09',
    },
    build_requires => {
        'Test::NoWarnings'  => 0,
        'Test::Exception'   => 0,
        'Test::Differences' => 0,
        'Test::Deep'        => 0,
        'Cwd'               => 0,
    },
    recommends => {
        # build
        'Test::Pod'            => '1.14',
        'Test::Pod::Coverage'  => '1.04',
        'Pod::Coverage::Moose' => 0,

    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script;
