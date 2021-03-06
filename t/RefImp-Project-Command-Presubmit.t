#!/usr/bin/env perl5.10.1

use strict;
use warnings;

use TestEnv;

use Sub::Install;
use Test::Exception;
use Test::More tests => 4;

my %setup;
subtest 'setup' => sub{
    plan tests => 1;

    $setup{pkg} = 'RefImp::Project::Command::Presubmit';
    use_ok($setup{pkg}) or die;

    $setup{project} = RefImp::Project->get(1);
    $setup{test_data_dir} = TestEnv::test_data_directory_for_package($setup{pkg});

    $setup{finisher} = RefImp::User->get(1);

    RefImp::Project::Finisher->create_for_project_and_user(
        project => $setup{project},
        user => $setup{finisher},
    );

    Sub::Install::reinstall_sub({
            code => sub{ diag $_[0]->as_string },
            into => 'MIME::Lite',
            as => 'send',
        });

    TestEnv::Clone::setup_test_lims_rest_api;
    TestEnv::Project::setup_test_overlaps;

    # Do not check LDAP for mail
    Sub::Install::reinstall_sub({
            code => sub{ undef },
            as => 'mail_for_unix_login',
            into => 'RefImp::Resources::LDAP',
        });

};

subtest 'cannot presubmit project with incorrect status' => sub{
    plan tests => 2;

    $setup{project}->status('prefinish_done');
    throws_ok(
        sub{
            $setup{pkg}->execute(
                project => $setup{project},
                checker_unix_logins => [ $setup{finisher}->unix_login ],
            );
        },
        qr/Project /,
        'fails w/ incorrect project status',
    );
    is($setup{project}->status, 'prefinish_done', 'did not presubmit')

};

subtest 'presubmit does not proceed unless responding yes' => sub{
    plan tests => 2;

    open my $stdin, '<', \ "NO\n"
        or die "Cannot open STDIN to read from string: $!";
    local *STDIN = $stdin;

    $setup{project}->status('finish_start');
    throws_ok(
        sub{
            $setup{pkg}->execute(
                project => $setup{project},
                checker_unix_logins => [ $setup{finisher}->unix_login ],
            ); 
        },
        qr/Request to not presubmit/,
        'failed to presubmit when responding no',
    );
    is($setup{project}->status, 'finish_start', 'did not presubmit')

};

subtest 'presubmit' => sub{
    plan tests => 2;

    open my $stdin, '<', \ "Y\n"
        or die "Cannot open STDIN to read from string: $!";
    local *STDIN = $stdin;

    my $cmd = $setup{pkg}->execute(
        project => $setup{project},
        checker_unix_logins => [ $setup{finisher}->unix_login ],
    );
    ok($cmd->result, 'execute');
    is($setup{project}->status, 'presubmitted', 'set project status');

};

done_testing();
