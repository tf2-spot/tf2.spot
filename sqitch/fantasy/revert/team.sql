-- Revert fantasy:team from pg

begin;

set search_path to fantasy;

drop table team;

commit;
