#!/usr/bin/env perl5.12.1

use strict;
use warnings;

use TestEnv;
use Test::More tests => 1;

use_ok('RefImp::Project::Command::BaseWithMany') or die;
done_testing();
