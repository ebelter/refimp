#!/usr/bin/env perl

use strict;
use warnings 'FATAL';




use TestEnv;

use File::Slurp;
use LWP::UserAgent;
use Sub::Install;
use Test::Exception;
use Test::MockObject;
use Test::More tests => 3;

my %setup;
subtest 'setup' => sub{
    plan tests => 2;

    $setup{pkg} = 'RefImp::Resources::Ncbi::Biosample';
    use_ok($setup{pkg}) or die;

    $setup{biosample} = 'SAMN06349363';
    $setup{bioproject} = 'PRJNA376014';

    $setup{ua} = TestEnv::NcbiBiosample->setup;
    ok($setup{ua}, 'biosample setup');

};

subtest 'create fails' => sub{
    plan tests => 3;

    throws_ok(sub{ $setup{pkg}->create(); }, qr/No bioproject/, 'fails w/o bioproject');
    throws_ok(sub{ $setup{pkg}->create(bioproject => $setup{bioproject}); }, qr/No biosample/, 'fails w/o biosample');

    my $response_elink = $setup{ua}->get('elink');
    $response_elink->set_false('is_success');
    throws_ok(sub{ $setup{pkg}->create(bioproject => $setup{bioproject}, biosample => $setup{biosample}); }, qr/Failed to GET.+elink/, 'fails when elink response is not success');
    $response_elink->set_true('is_success');

};

subtest 'create' => sub{
    plan tests => 7;

    my $biosample = $setup{pkg}->create(bioproject => $setup{bioproject}, biosample => $setup{biosample});
    ok($biosample, 'create biosample');

    my $expected_url = sprintf('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?dbfrom=bioproject&db=biosample&id=%s', $biosample->biosample_uid);
    is($biosample->esummary_url, $expected_url, 'correct esummary url');
    $expected_url = sprintf('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=bioproject&db=biosample&id=%s', $biosample->bioproject_uid);
    is($biosample->elink_url, $expected_url, 'correct elink url');

    is($biosample->biosample, 'SAMN06349363', 'biosample');
    is($biosample->biosample_uid, '6349363', 'biosample_uid');
    is($biosample->bioproject, 'PRJNA376014', 'bioproject');
    is($biosample->bioproject_uid, '376014', 'bioproject_uid');

};

done_testing();
