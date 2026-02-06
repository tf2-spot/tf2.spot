-- Revert fantasy:v0/manager to pg

begin;

set search_path to fantasy_v0;

drop view manager;

commit;
