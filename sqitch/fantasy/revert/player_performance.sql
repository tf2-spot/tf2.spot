-- Revert fantasy:player_performance to pg

begin;

set search_path to fantasy;

drop table player_performance;

commit;
