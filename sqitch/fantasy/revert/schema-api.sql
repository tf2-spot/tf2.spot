-- Revert fantasy:schema-api from pg

BEGIN;

drop schema fantasy_api;

COMMIT;
