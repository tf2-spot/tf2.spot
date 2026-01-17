-- Revert meta:mathesar_user from pg

begin;

revoke connect, create on database postgres from mathesar;

drop user mathesar;

commit;
