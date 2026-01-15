-- Revert meta:mathesar_user from pg

BEGIN;

revoke connect, create on database postgres from mathesar;

drop user mathesar;

COMMIT;
