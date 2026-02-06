-- Revert fantasy:player from pg

begin;

set search_path to fantasy;

drop table player;

commit;
