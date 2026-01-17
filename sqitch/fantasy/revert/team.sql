-- Revert fantasy:team from pg

begin;

set search_path to fantasy, public;

drop table team;

commit;
