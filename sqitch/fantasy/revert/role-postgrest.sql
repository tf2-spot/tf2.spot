-- Revert fantasy:role-postgrest from pg

BEGIN;

drop user fantasy_postgrest;

COMMIT;
