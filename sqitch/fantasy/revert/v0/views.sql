-- Revert fantasy:v0/tournament to pg

begin;

set search_path to fantasy_v0;

drop function time_signed(contract);
drop function time_terminated(contract);
drop function player_performance(participant);
drop function player_coefficient(player_performance);

drop view manager;
drop view me;
drop view tournament;
drop view composition;
drop view scoring_model;
drop view player_coefficient;
drop view player_statistic;
drop view team_coefficient;
drop view team_statistic;
drop view round;
drop view team;
drop view participant;
drop view player;
drop view player_performance;
drop view fantasy;
drop view my_fantasy;
drop view contract;

commit;
