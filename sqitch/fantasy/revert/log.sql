-- Revert fantasy:log from pg

begin;

set search_path to fantasy, public;

drop table log;

commit;
