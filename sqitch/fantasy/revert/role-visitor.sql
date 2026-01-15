-- Revert fantasy:role-visitor from pg

BEGIN;

drop role fantasy_visitor;

COMMIT;
