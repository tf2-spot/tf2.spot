-- Revert fantasy:role-postgrest from pg

begin;

drop user fantasy_postgrest;

commit;
