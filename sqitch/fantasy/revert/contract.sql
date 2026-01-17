-- Revert fantasy:contract from pg

begin;

set search_path to fantasy, public;

drop table contract;

commit;
