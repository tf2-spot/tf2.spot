-- Revert fantasy:team_performance to pg

begin;

set search_path to fantasy;

drop materialized view team_performance;

commit;
