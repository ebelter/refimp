package RefImp::Tenx::SampleSheet;

use strict;
use warnings;

use IO::File;
use List::MoreUtils;
use Path::Class;
use Text::CSV;

class RefImp::Tenx::SampleSheet { 
    has => {
        samples => { is => 'ARRAY', },
    },
    doc => 'sample sheet for running mkfastq and creating reads db entries',
};

sub load_from_file {
    my ($class, $file) = @_;

    $class->fatal_message('No sample sheet file given!') if not $file;
    $class->fatal_message('Sample sheet file given does not exist!') if not -s $file;

    my $fh = IO::File->new($file, 'r');
    $class->fatal_message('Failed to open %s => %s', $file, $!) if not $fh;

    my $csv = Text::CSV->new({sep_char => ','});
    $class->fatal_message('Failed to create Text::CSV object!') if not $csv;

    my $column_names;
    do {
        $column_names = $csv->getline($fh);
    } until not defined $column_names or List::MoreUtils::any { /^sample/i } @$column_names;
    $class->fatal_message('No sample column found in %s', $file) if not $column_names or not @$column_names;
    $csv->column_names(@$column_names);

    my @samples;
    while ( my $info = $csv->getline_hr($fh) ) {
        my %sample = map { my $v = delete $info->{$_}; lc $_ => $v } keys %$info;
        $class->fatal_message('No index found in %s', Data::Dumper::Dumper($info)) if not $sample{index};

        my $sample_key = List::MoreUtils::firstval { exists $sample{$_} } (qw/ sample sample_id /);
        $class->fatal_message('No sample key found in %s', Data::Dumper::Dumper($info)) if not $sample_key;
        $sample{name} = delete $sample{$sample_key};
        $class->fatal_message('No sample name found for %s in %s', $sample_key, Data::Dumper::Dumper($info)) if not $sample{name};

        $class->fatal_message('No lane found for sample %s', Data::Dumper::Dumper($info)) if not $sample{lane};

        my $project_key = List::MoreUtils::firstval { exists $sample{$_} } (qw/ project sample_project /);
        $sample{project} = delete $sample{$project_key} if $project_key;

        push @samples, \%sample;
    }

    $class->create(samples => \@samples);
}

sub sample_names {
    my $self = shift;
    my @names = sort map { $_->{name} } @{$self->samples};
    List::MoreUtils::uniq @names;
}

sub lanes {
    my $self = shift;
    my @lanes = sort map { $_->{lane} } @{$self->samples};
    List::MoreUtils::uniq @lanes;
}

1;
