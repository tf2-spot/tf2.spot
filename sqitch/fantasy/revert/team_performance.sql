-- Revert fantasy:team_performance to pg

begin;

set search_path to fantasy;

drop table team_performance;

commit;
