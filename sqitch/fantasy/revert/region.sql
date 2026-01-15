-- Revert fantasy:region from pg

BEGIN;

drop table fantasy.region;

COMMIT;
