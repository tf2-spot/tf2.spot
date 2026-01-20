-- Revert fantasy:composition to pg

begin;

set search_path to fantasy, public;

drop table composition;

commit;
