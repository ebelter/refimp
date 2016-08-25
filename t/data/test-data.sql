-- Deploy refimp:test_data to sqlite

BEGIN;

INSERT OR IGNORE INTO projects (project_id, name) VALUES (1, 'HMPB-AAD13A05');
INSERT OR IGNORE INTO clones (clo_id, clone_name, cs_clone_status, ct_clone_type) VALUES (1, 'HMPB-AAD13A05', 'active', 'plasmid');

INSERT OR IGNORE INTO gsc_users (gu_id, unix_login) VALUES (1, 'bobama');
INSERT OR IGNORE INTO user_function (ei_id, gu_id, status) VALUES (-33, 1, 'active');
INSERT OR IGNORE INTO work_function (function_id, name, status) VALUES (-33, 'finish', 'active');
INSERT OR IGNORE INTO user_function (ei_id, gu_id, status) VALUES (-34, 1, 'inactive');
INSERT OR IGNORE INTO work_function (function_id, name, status) VALUES (-34, 'prefinish', 'inactive');
INSERT OR IGNORE INTO user_function (ei_id, gu_id, status) VALUES (-35, 1, 'inactive');
INSERT OR IGNORE INTO work_function (function_id, name, status) VALUES (-35, 'qc', 'inactive');

COMMIT;