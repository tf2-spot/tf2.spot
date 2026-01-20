-- Revert fantasy:player_statistic from pg

begin;

set search_path to fantasy, public;

drop table player_statistic;

commit;
