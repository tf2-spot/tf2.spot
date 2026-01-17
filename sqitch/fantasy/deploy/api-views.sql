-- Deploy fantasy:api-views to pg

begin;

set search_path to fantasy_api, fantasy, public;

create view tournament as
select tournament.*
     , count(real_team.id) as real_team_count
     , count(participant.id) as participant_count
     , count(team.id) as team_count
from tournament
join real_team on tournament.id = real_team.tournament
join participant on real_team.id = participant.real_team
join team on tournament.id = team.tournament
group by tournament.id;

commit;
