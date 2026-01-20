-- Revert fantasy:player_performance to pg

begin;

set search_path to fantasy, public;

drop table player_performance;

commit;
