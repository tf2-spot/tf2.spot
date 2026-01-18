-- Revert fantasy:coefficient from pg

begin;

set search_path to fantasy, public;

drop table coefficient;

commit;
