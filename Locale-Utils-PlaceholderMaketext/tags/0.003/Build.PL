use strict;
use warnings;

use Module::Build;

Module::Build->new(
    module_name       => 'Locale::Utils::PlaceholderMaketext',
    license           => 'perl',
    dist_abstract     => 'Locale::Utils::PlaceholderMaketext - Utils to expand maketext placeholders',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Locale/Utils/PlaceholderMaketext.pm',
    requires          => {
        perl                      => '5.006',
        Carp                      => 0,
        Moo                       => '1.003001',
        'MooX::StrictConstructor' => 0,
        'MooX::Types::MooseLike'  => 0,
        'namespace::autoclean'    => 0,
        'Scalar::Util'            => 0, # dist Perl
    },
    build_requires => {
        'Test::NoWarnings'  => 0,
        'Test::Exception'   => 0,
        'Test::Differences' => '0.60',
        'Test::More'        => 0, # dist Test-Simple
    },
    recommends => {
        'Test::Pod'            => '1.14',
        'Test::Pod::Coverage'  => '1.04',
        'Pod::Coverage::Moose' => 0,
    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 0,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script;
