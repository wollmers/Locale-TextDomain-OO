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
        'charnames'                          => 0, # perl dist
        'namespace::autoclean'               => 0,
        'Carp'                               => 0, # perl dist
        'Encode'                             => 0, # perl dist
        'English'                            => 0, # perl dist
        'File::Spec'                         => 0, # perl dist
        'JSON'                               => 0, # perl dist
        'List::MoreUtils'                    => 0, # perl dist
        'Locale::MO::File'                   => 0,
        'Locale::Utils::PlaceholderMaketext' => 0,
        'Locale::Utils::PlaceholderNamed'    => 0,
        'Moo'                                => 0,
        'Moo::Role'                          => 0,
        'MooX::Singleton'                    => 0,
        'MooX::StrictConstructor'            => 0,
        'MooX::Types::MooseLike::Base'       => 0,
        'Path::Class'                        => 0,
        'Path::Class::Rule'                  => 0,
        'Safe'                               => 0, # perl dist
        'Tie::Sub'                           => '0.09',
    },
    build_requires => {
        'Cwd'               => 0, # perl dist
        'Test::Exception'   => 0, # perl dist
        'Test::Differences' => '0.60', # perl dist
        'Test::More'        => 0, # dist Test-Simple (perl dist)
        'Test::NoWarnings'  => 0,
    },
    recommends => {
        'Test::Pod'            => '1.14',
        'Test::Pod::Coverage'  => '1.04',
    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 0,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script;
