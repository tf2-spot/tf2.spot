-- Revert fantasy:player_statistic from pg

begin;

set search_path to fantasy;

drop table player_statistic;

commit;
