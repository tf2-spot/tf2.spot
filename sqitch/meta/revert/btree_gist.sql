-- Revert meta:btree_gist from pg

begin;

drop extension btree_gist;

commit;
