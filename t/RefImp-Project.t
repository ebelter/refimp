#!/usr/bin/env perl5.10.1

use strict;
use warnings;

use TestEnv;

use File::Spec qw();
use Test::More tests => 4;

my $project;
subtest "basics" => sub{
    plan tests => 6;

    use_ok('RefImp::Project') or die;

    $project = RefImp::Project->get(1);
    ok($project, 'got project');
    ok($project->name, 'project has a name');
    can_ok($project, 'directory');

    my $expected_directory = File::Spec->join( RefImp::Config::get('seqmgr'), $project->name);
    is($project->directory, $expected_directory, 'directory');
    is($project->directory_for_name($project->name), $expected_directory, 'directory_for_name');

};

subtest "status" => sub{
    plan tests => 3;

    my @psh = $project->status_histories;
    ok(!@psh, 'no project status histories');
    is($project->status('finish_start'), 'finish_start', 'set status');
    @psh = $project->status_histories;
    is(@psh, 1, 'added psh');

};

subtest "claimers" => sub{
    plan tests => 7;

    use_ok('RefImp::Project::Claimer') or die;

    for my $type ( RefImp::Project::Claimer::valid_claim_types() ) {
        my $add_method = 'add_claimed_as_'.$type;
        my $claimer = $project->$add_method(ei_id => -11);
        ok($claimer, "created project $type");
        my $claimed_as_method = 'claimed_as_'.$type;
        is($project->$claimed_as_method, $claimer, "added $type to project");
    }

};

subtest 'notes file' => sub{
    plan tests => 3;

    my $notes_file_path = $project->notes_file_path;
    ok($notes_file_path, 'notes_file_path');
    ok(-s $notes_file_path, 'notes_file_path exists');
    ok($project->notes_file, 'notes_file');

};

done_testing();
