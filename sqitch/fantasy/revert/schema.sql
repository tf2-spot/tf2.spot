-- Revert fantasy:schema from pg

BEGIN;

drop schema fantasy;

COMMIT;
