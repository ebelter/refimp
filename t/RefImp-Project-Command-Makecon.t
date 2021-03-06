#!/usr/bin/env perl5.10.1

use strict;
use warnings;

use TestEnv;

use File::Compare;
use File::Spec;
use File::Temp;
use Sub::Install;
use Test::More tests => 3;

my $pkg_name = 'RefImp::Project::Command::Makecon';
use_ok($pkg_name) or die;

my $tempdir = File::Temp::tempdir(CLEANUP => 1);
my $project = RefImp::Project->get(1);
$project->status('finish_start');
TestEnv::Clone::setup_test_lims_rest_api;

subtest 'from analysis directory' => sub{
    plan tests => 3;

    my $output_file = File::Spec->join($tempdir, 'from_analysis_dir.con');
    my $makecon = $pkg_name->execute(
        project => $project,
        output_file => $output_file,
    );
    ok($makecon->result, 'execute');
    ok(-s $output_file, 'wrote output_file');

    my $expected_output_file = File::Spec->join(TestEnv::test_data_directory_for_package($pkg_name), 'HMPB-AAD13A05.from-submission.con');
    is(File::Compare::compare($output_file, $expected_output_file), 0, 'output file matches');

};

subtest 'from recent ace' => sub{
    plan tests => 3;

    Sub::Install::reinstall_sub({
            code => sub{ undef },
            into => $pkg_name,
            as => '_get_sequence_from_most_recent_submission',
        });

    my $output_file = File::Spec->join($tempdir, 'from_ace.con');
    my $makecon = $pkg_name->execute(
        project => $project,
        output_file => $output_file,
    );
    ok($makecon->result, 'execute');
    ok(-s $output_file, 'wrote output_file');

    my $expected_output_file = File::Spec->join(TestEnv::test_data_directory_for_package($pkg_name), 'HMPB-AAD13A05.from-ace.con');
    is(File::Compare::compare($output_file, $expected_output_file), 0, 'output file matches');
};

done_testing();
