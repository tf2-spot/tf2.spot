-- Revert fantasy:player from pg

begin;

set search_path to fantasy, public;

drop table player;

commit;
