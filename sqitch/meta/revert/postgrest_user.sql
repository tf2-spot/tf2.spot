-- Revert meta:postgrest_user to pg

begin;

drop user postgrest;

commit;
