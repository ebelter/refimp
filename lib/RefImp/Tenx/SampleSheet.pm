package RefImp::Tenx::SampleSheet;

use strict;
use warnings;

use IO::File;
use List::MoreUtils;
use Path::Class;
use Params::Validate qw/ :types validate_pos /;
use Text::CSV;

class RefImp::Tenx::SampleSheet { 
    has => {
        directory => { is => 'Path::Class::Dir', },
        samples => { is => 'ARRAY', },
    },
    has_optional => {
        project_name => { is => 'Text', },
    },
    doc => 'sample sheet for running mkfastq and creating reads db entries',
};

sub create_from_mkfastq_directory {
    my ($class, $directory) = @_;

    $class->fatal_message('No mkfastq directory given!') if not $directory;
    $class->fatal_message('Mkfastq directory given does not exist: %s', $directory) if !-d $directory;

    $directory = dir($directory);
    my $file = $directory->subdir('outs')->file('input_samplesheet.csv');
    $class->fatal_message('No samplesheet found in mkfastq directory: %s', $file) if !-s $file->stringify;

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

    my $project_name;
    my $invocation_file = $directory->file('_invocation');
    if ( -s $invocation_file ) {
        $project_name = $class->get_project_from_invocation($invocation_file);
    }

    my %params = (
        directory => $directory,
        samples => \@samples,
    );
    $params{project_name} = $project_name if $project_name;

    $class->create(%params);
}

sub get_project_from_invocation {
    my ($class, $invocation_file) = validate_pos(@_, {is => __PACKAGE__}, {is => SCALAR});

    my $fh = IO::File->new($invocation_file, 'r');
    $class->fatal_message('Failed to open: %s', $invocation_file) if not $fh;
    my $project;
    while ( my $line = $fh->getline ) {
        next if $line !~ /project\s+=\s+"(.+)"/;
        $project = $1;
        last;
    }
    $fh->close;

    $project;
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

sub fastq_directory_for_sample_name {
    my ($self, $sample_name) = validate_pos(@_, {is => __PACKAGE__}, {is => SCALAR});

    # Fastq Finder
    my $has_fastqs = sub{
        my $fq_dir = shift;
        return if not -d $fq_dir;
        my $fq_pattern = $fq_dir->file('*.fastq*');
        my @fastq_files = glob($fq_pattern);
        return @fastq_files;
    };

    # Check if there is a sample directory in the main directory
    my $directory = $self->directory;
    my $sample_directory = $directory->subdir($sample_name);
    return $sample_directory if $has_fastqs->($sample_directory);

    # Check in the project directories
    my @project_names = List::MoreUtils::uniq map { $_->{project} } grep { defined $_->{project} and $_->{name} eq $sample_name } @{$self->samples};
    unshift @project_names, $self->project_name if $self->project_name;
    for my $project_name ( @project_names ) {
        $sample_directory = $directory->subdir($project_name)->subdir($sample_name);
        return $sample_directory if $has_fastqs->($sample_directory);
    }

    $self->fatal_message('Could not find fastqs for sample: %s', $sample_name);
}

1;
