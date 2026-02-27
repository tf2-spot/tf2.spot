-- Deploy fantasy:v0/tournament to pg

begin;

set search_path to fantasy_v0;

create view manager as
select steam_id
     , case when muted_until > now() or name is null then 'Manager #' || steam_id else name end as name
     , case when muted_until > now() then null else avatar end as avatar
     , last_login
     , fetched
from fantasy.manager;

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

create view team as
select * from fantasy.team;

create view participant as
select * from fantasy.participant;

create view player as
select * from fantasy.player;

create view player_performance as
select * from fantasy.player_performance;

create view fantasy as
select id
     , tournament
     , manager
     , case when muted_until > now() or fantasy.name is null then 'Unnamed team' else fantasy.name end as name
     , initial_budget
from fantasy.fantasy
join fantasy.manager on manager.steam_id = fantasy.manager;

create view my_fantasy as
select *
from fantasy.fantasy
where manager = current_setting('request.jwt.claims', true)::json->>'manager_id';

create view contract as
select * from fantasy.contract;

create function time_signed(contract)
returns timestamptz
language sql
as $$
    select lower($1.time);
$$;

create function time_terminated(contract)
returns timestamptz
language sql
as $$
    select upper($1.time);
$$;


create function player_performance(participant)
returns setof player_performance
stable
language sql
as $$
  select * from player_performance where participant = $1.id
$$;

create function player_coefficient(player_performance)
returns setof player_coefficient rows 1
stable
language sql
as $$
  select * from player_coefficient where id = $1.player_coefficient
$$;

commit;
