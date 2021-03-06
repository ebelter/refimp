package RefImp::Resources::Ncbi::ParseAc4htgsReport;

use strict;
use warnings;

use File::Basename 'basename';
use Params::Validate qw/ :types validate_pos /;

sub parse {
    my ($class, $file) = validate_pos(@_, {isa => __PACKAGE__}, {type => SCALAR});

    my $fh = IO::File->new($file, 'r');
    die "Failed to open $file" if not $fh;

    my %report;
    while ( my $line = $fh->getline ) {
        chomp $line;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        my ($key, $value) = split(': ', $line, 2);
        next if not defined $value;
        $report{$key} = $value;
    }
    $fh->close;

    my $file_name = basename($file);
    my @file_name_tokens = split(/\./, $file_name);
    $report{localseqname} = $file_name_tokens[1];

    @report{qw/ accession version /} = split(/\./, delete $report{accession});

    return \%report;
}

1;

