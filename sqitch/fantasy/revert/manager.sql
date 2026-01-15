-- Revert fantasy:manager from pg

BEGIN;

drop table fantasy.manager;

COMMIT;
