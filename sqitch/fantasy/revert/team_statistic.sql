-- Revert fantasy:team_statistic to pg

begin;

set search_path to fantasy;

drop table team_statistic;

commit;
