-- Revert fantasy:role-manager from pg

BEGIN;

drop role fantasy_manager;

COMMIT;
