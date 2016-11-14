#!/usr/bin/env perl5.10.1

use strict;
use warnings;

use TestEnv;

use File::Temp;
use Test::Exception;
use Test::More tests => 5;

my $pkg = 'RefImp::Project::Submissions';
use_ok($pkg) or die;

my $clone = RefImp::Clone->get(1);
TestEnv::Clone::setup_test_lims_rest_api;

subtest 'analysis directories' => sub{
    plan tests => 4;

    my $analysis_directory = RefImp::Config::get('analysis_directory');
    ok($analysis_directory, 'analysis_directory');
    ok(-d $analysis_directory, 'analysis_directory exists');

    is(
        $pkg->analysis_directory_for_taxon( $clone->taxonomy ),
        File::Spec->join($analysis_directory, $clone->taxonomy->species_short_name),
        'analysis_directory_for_taxon',
    );

    is(
        $pkg->analysis_directory_for_clone($clone),
        File::Spec->join($analysis_directory, $clone->taxonomy->species_short_name, lc($clone->name)),
        'analysis_directory_for_clone',
    );

};

subtest 'analysis clone subdirectories' => sub{
    plan tests => 3;

    throws_ok(sub{ $pkg->new_analysis_subdirectory_for_clone; }, qr/but 2 were expected/, 'fails w/o clone');

    my $tempdir = File::Temp::tempdir(CLEANUP => 1);
    my $analysis_directory = RefImp::Config::set('analysis_directory', $tempdir);
    RefImp::Config::set('analysis_directory', $tempdir);

    my $new_directory = $pkg->new_analysis_subdirectory_for_clone($clone);
    ok($new_directory, 'got subdirectory');
    my $expected_directory = File::Spec->join($tempdir, $clone->taxonomy->species_short_name, lc($clone->name), '\d{8}');
    like($new_directory, qr/$expected_directory/, 'subdirectory named correctly');

    RefImp::Config::set('analysis_directory', $analysis_directory);

};

subtest 'file names' => sub{
    plan tests => 3;

    is($pkg->submit_form_file_name_for_clone($clone), join('.', $clone->name, 'submit', 'form'), 'submit_form_file_name');
    throws_ok(
        sub{ $pkg->submit_info_yml_file_name_for_clone; },
        qr/but 2 were expected/,
        'submit yml file name fails w/o clone'
    );
    is($pkg->submit_info_yml_file_name_for_clone($clone), join('.', $clone->name, 'submit', 'yml'), 'submit_form_file_name');

};

subtest 'templates' => sub{
    plan tests => 1;

    my $analysis_directory = RefImp::Config::get('analysis_directory');
    is(
        $pkg->raw_sqn_template_for_taxon( $clone->taxonomy ),
        File::Spec->join($analysis_directory, 'templates', 'raw_'.$clone->taxonomy->species_short_name.'_template.sqn'),
        'raw_sqn_template_for_taxon',
    );

};

done_testing();
