-- Revert fantasy:tournament from pg

begin;

set search_path to fantasy, public;

drop table tournament;

commit;
