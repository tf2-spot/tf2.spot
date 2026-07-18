-- Revert fantasy:role-admin from pg

begin;

drop user fantasy_admin;

commit;
