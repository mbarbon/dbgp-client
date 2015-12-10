#!/usr/bin/perl

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'DBGp::Client',
    license     => 'perl',
    configure_requires => {
        'Module::Build' => 0.42,
    },
    requires    => {
        'perl'                  => '5.10.1',
        'XML::Parser'           => 0,
        'XML::Parser::EasyTree' => 0,
    },
);
$build->create_build_script;
