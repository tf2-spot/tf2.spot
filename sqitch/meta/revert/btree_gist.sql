-- Revert meta:btree_gist from pg

BEGIN;

drop extension btree_gist;

COMMIT;
