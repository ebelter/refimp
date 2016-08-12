package TestEnv;

use strict;
use warnings;

use File::Basename 'dirname';
use File::Spec;
use Sys::Hostname;

INIT { # runs after compilation, right before execution
    $ENV{REFIMP_CONFIG_FILE} = '/gscuser/ebelter/dev/refimp-env/config.test.yml';
    $ENV{UR_USE_DUMMY_AUTOGENERATED_IDS} = 1;
    $ENV{UR_DBI_NO_COMMIT} = 1;

    my $lib = resolve_lib_path( (caller())[1] );
    eval "use lib '$lib';";
    die "FATAL: $@" if $@;

    my $use = <<USE;
    use RefImp;
    use RefImp::Test;
    use RefImp::Test::Factory;
USE
    eval $use;
    die "FATAL: $@" if $@;

    printf(STDERR "***** TEST ENV on %s *****\n", Sys::Hostname::hostname);
}

sub resolve_lib_path {
    my $file = shift;
    die "No file given to resolve lib path!" if not $file;
    die "File given to resolve lib path does not exist!" if not -e $file;
    my @directory_parts = File::Spec->splitdir( File::Spec->rel2abs( dirname($file) ) );
    splice @directory_parts, -1, 1, 'lib';
    File::Spec->join(@directory_parts);
}

1;

