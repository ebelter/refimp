package RefImp::Project::Saver;

use strict;
use warnings;

=pod

PROJECT_SAVERS	GSC::ProjectSaver	oltp	production

  x EI_EI_ID           ei_id      NUMBER(10)  (pk)(fk)
  x PROJECT_PROJECT_ID project_id NUMBER(10)  (pk)(fk)

=cut

class RefImp::Project::Saver { 
    is => 'RefImp::Project::Claimer', 
    table_name => 'project_savers',
    data_source => RefImp::Config::get('ds_oltp'),
    id_by => {
        project_id => { is => 'Integer', column_name => 'project_project_id', },
        ei_id => { is => 'Integer', column_name => 'ei_ei_id', },
    },
};

sub claimer_type { 'saver' }

1;

