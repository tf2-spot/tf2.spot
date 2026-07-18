-- Revert fantasy:contract from pg

begin;

set search_path to fantasy;

drop table contract;

commit;
