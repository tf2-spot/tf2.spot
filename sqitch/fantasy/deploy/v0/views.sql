-- Deploy fantasy:v0/tournament to pg

begin;

set search_path to fantasy_v0;

create view manager as
select * from fantasy.manager;

create view me as
select *
from fantasy.manager
where steam_id = current_setting('request.jwt.claims', true)::json->>'manager_id';

create view tournament as
select * from fantasy.tournament;

create view scoring_model as
select * from fantasy.scoring_model;

create view player_coefficient as
select * from fantasy.player_coefficient;

create view player_statistic as
select * from fantasy.player_statistic;

create view team_coefficient as
select * from fantasy.team_coefficient;

create view team_statistic as
select * from fantasy.team_statistic;

create view composition as
select * from fantasy.composition;

create view round as
select * from fantasy.round;

commit;
