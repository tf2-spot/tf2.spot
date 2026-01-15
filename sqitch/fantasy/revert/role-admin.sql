-- Revert fantasy:role-admin from pg

BEGIN;

drop user fantasy_admin;

COMMIT;
