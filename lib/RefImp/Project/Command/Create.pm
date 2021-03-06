package RefImp::Project::Command::Create;

use strict;
use warnings;

use RefImp::Project;

class RefImp::Project::Command::Create { 
    is => 'Command::V2',
    has_input => {
        name => {
            is => 'Text',
            doc => 'Name of the project. Should match the clone name.',
        },
    },
    has_optional_input => {
        directory => {
            is => 'Text',
            doc => 'Base directory to create project structure in.',
        },
        status => {
            is => 'Text',
            default_value => 'prefinish_start',
            doc => 'Starting status of the project.',
        },
    },
    has_optional_transient => {
        project => {
            is => 'RefImp::Project',
            doc => 'The newly created project.',
        },
    },
    doc => 'create a project',
};

sub help_detail { __PACKAGE__->__meta__->doc }

sub execute {
    my $self = shift; 
    $self->status_message('Create project...');

    my %params = (
        name => $self->name,
        priority => 0,
        purpose => 'finishing',
        target => 0,
    );
    $self->status_message("Project params:\n%s---\n", YAML::Dump(\%params));
    my $project = RefImp::Project->get(%params);
    $self->fatal_message('Project already exists: %s', $project->__display_name__) if $project;

    $project = RefImp::Project->create(%params);
    $self->fatal_message('Failed to create project!') if !$project;
    $self->project($project);
    $self->status_message('New project: %s', $project->__display_name__);

    $self->status_message('Checking for matching clone...');
    my $clone = RefImp::Clone->get(name => $project->name);
    if ( $clone ) {
        $self->status_message('Found matching RefImp::Clone: ', $clone->__display_name__);
    }
    else {
        $self->warning_message('No matching RefImp::Clone found with name: %s', $project->name);
    }

    if ( $self->directory ) {
        RefImp::Project::Command::Update::Directory->execute(
            projects => [$project],
            value => $self->directory,
        );
    }

    if ( $self->status ) {
        $self->status_message('Set project status: %s', $self->status);
        $project->status( $self->status );
    }

    return 1;
}

1;

