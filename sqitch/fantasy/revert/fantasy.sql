-- Revert fantasy:fantasy from pg

begin;

set search_path to fantasy, public;

drop table fantasy;

commit;
