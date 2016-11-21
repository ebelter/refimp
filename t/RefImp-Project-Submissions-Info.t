#!/usr/bin/env perl5.10.1

use strict;
use warnings;

use TestEnv;

use File::Spec;
use Test::More tests => 3;
use YAML;

my $pkg = 'RefImp::Project::Submissions::Info';
use_ok($pkg) or die;

my $expected_hash = YAML::LoadFile( File::Spec->join(TestEnv::test_data_directory_for_package($pkg), 'expected.yml') );
TestEnv::Clone::setup_test_lims_rest_api;

subtest 'generate' => sub{
    plan tests => 1;

    my $project = RefImp::Project->get(1);
    my $hash = $pkg->generate($project);
    is_deeply($hash, $expected_hash, 'hash matches');

};

subtest 'load' => sub{
    plan tests => 1;

    my $hash = $pkg->load( File::Spec->join(TestEnv::test_data_directory_for_package($pkg), 'expected.yml') );
    is_deeply($hash, $expected_hash, 'hash matches');

};

done_testing();