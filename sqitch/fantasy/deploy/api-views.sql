-- Deploy fantasy:api-views to pg

begin;

set search_path to fantasy_api, fantasy, public;

create view tournament as
select tournament.*
     , count(team.id) as team_count
     , count(fantasy.id) as fantasy_count
from tournament
left join team on team.tournament = tournament.id
left join fantasy on fantasy.tournament = tournament.id
group by tournament.id;

commit;
