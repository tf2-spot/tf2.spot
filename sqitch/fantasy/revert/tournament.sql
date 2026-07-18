-- Revert fantasy:tournament from pg

begin;

set search_path to fantasy;

drop table tournament;

commit;
