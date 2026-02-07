-- Revert fantasy:player_performance to pg

begin;

set search_path to fantasy;

drop materialized view player_performance;

commit;
