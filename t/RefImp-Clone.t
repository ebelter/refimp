#!/usr/bin/env perl5.10.1

use strict;
use warnings;

use TestEnv;

use File::Spec qw();
use Test::More tests => 4;

my $clone;
subtest "basics" => sub{
    plan tests => 6;

    use_ok('RefImp::Clone') or die;

    $clone = RefImp::Clone->get(1);
    ok($clone, 'got clone');
    ok($clone->name, 'clone has a name');
    ok($clone->__display_name__, '__display_name__');
    ok($clone->type, 'clone has a type');
    ok($clone->status, 'clone has a status');

};

subtest 'taxonomy' => sub {
    plan tests => 4;

    TestEnv::Clone::setup_test_lims_rest_api;

    my $taxon = $clone->taxonomy;
    ok($taxon, 'taxon');
    is($clone->species_name, $taxon->species_name, 'species_name');
    is($clone->species_latin_name,  $taxon->species_latin_name, 'species_latin_name');
    is($clone->chromosome, $taxon->chromosome, 'chromosome');

};

subtest 'ace0' => sub{
    plan tests => 3;

    my $ace0_path = $clone->ace0_path;
    ok($ace0_path, 'ace0_path');
    like($ace0_path, qr/\.ace\.0$/, 'ace0_path named correctly');
    ok(-s $ace0_path, 'ace0_path exixsts');

};

subtest 'project' => sub{
    plan tests => 3;

    my $project = RefImp::Project->get(1);
    ok($project, 'got project');
    is($clone->project, $project, 'got project via clone');

    $project->status('new');
    is($clone->project_status, 'new', 'project_status');

};

done_testing();
