-- Revert fantasy:fantasy from pg

begin;

set search_path to fantasy;

drop table fantasy;

commit;
