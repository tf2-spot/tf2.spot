-- Revert fantasy:composition to pg

begin;

set search_path to fantasy;

drop table composition;

commit;
