-- Revert fantasy:manager from pg

begin;

set search_path to fantasy, public;

drop table manager;

commit;
