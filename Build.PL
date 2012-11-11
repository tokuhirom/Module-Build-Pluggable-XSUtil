use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    dynamic_config       => 0,

    build_requires       => {
        'Test::More' => '0.98',
        'Test::Requires' => 0,
    },
    configure_requires   => { 'Module::Build' => '0.38' },
    requires             => {
        perl => '5.010001',
        'parent'                        => '0',
        'Exporter'                      => '0',
        'Devel::PPPort'                 => 3.19,
        'XSLoader'                      => 0.02,
        'ExtUtils::ParseXS'             => '2.21',
        'Devel::CheckLib'               => 0.04,
        'Devel::CheckCompiler'          => 0,
        'Module::Build::Pluggable'      => 0.04,
    },

    needs_compiler => 1, # really?

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Module-Build-Pluggable-XSUtil',
    module_name => 'Module::Build::Pluggable::XSUtil',

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
   
    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
