-- Deploy fantasy:team_performance to pg

begin;

set search_path to fantasy;

create materialized view team_performance as
with extract as (
select log_id
     , json_table.*
from logstf_document, json_table(document, '$' columns
( red_score        int path '$.teams.Red.score'
, red_kills        int path '$.teams.Red.kills'
, red_deaths       int path '$.teams.Red.deaths'
, red_damage       int path '$.teams.Red.dmg'
, red_ubercharges  int path '$.teams.Red.charges'
, red_drops        int path '$.teams.Red.drops'
, red_first_caps   int path '$.teams.Red.firstcaps'
, red_caps         int path '$.teams.Red.caps'
, red_medic_deaths int[] path '$.players.keyvalue().value ? (@.team == "Red").class_stats[*] ? (@.type == "medic").deaths' with wrapper
, red_players      text[] path '$.players.keyvalue() ? (@.value.team == "Red").key' with wrapper

, blue_score        int path '$.teams.Blue.score'
, blue_kills        int path '$.teams.Blue.kills'
, blue_deaths       int path '$.teams.Blue.deaths'
, blue_damage       int path '$.teams.Blue.dmg'
, blue_ubercharges  int path '$.teams.Blue.charges'
, blue_drops        int path '$.teams.Blue.drops'
, blue_first_caps   int path '$.teams.Blue.firstcaps'
, blue_caps         int path '$.teams.Blue.caps'
, blue_medic_deaths int[] path '$.players.keyvalue().value ? (@.team == "Blue").class_stats[*] ? (@.type == "medic").deaths' with wrapper
, blue_players      text[] path '$.players.keyvalue() ? (@.value.team == "Blue").key' with wrapper
))
)

, steamid64 as (
select log_id
     , array_agg(to_steamid64(p.red)::text) as red_players
     , array_agg(to_steamid64(p.blue)::text) as blue_players
from extract, unnest(red_players, blue_players) p(red, blue)
group by log_id
)

, team_side as (
select extract.log_id
     , count(1) filter (
       where (participant.team = match.team_a and (
         participant.player = any(steamid64.red_players)
         or substitution.substitute = any(steamid64.red_players)
       ))
       or (participant.team = match.team_b and (
         participant.player = any(steamid64.blue_players)
         or substitution.substitute = any(steamid64.blue_players)
       ))
     )
     > count(1) filter (
       where (participant.team = match.team_a and (
         participant.player = any(steamid64.blue_players)
         or substitution.substitute = any(steamid64.blue_players)
       ))
       or (participant.team = match.team_b and (
         participant.player = any(steamid64.red_players)
         or substitution.substitute = any(steamid64.red_players)
       ))
     )
     as team_a_is_red
from extract
join steamid64 on steamid64.log_id = extract.log_id
join map on extract.log_id in (map.log_id, map.golden_cap_log_id)
join match on match.id = map.match
join participant on participant.team in (match.team_a, match.team_b)
left join substitution
  on substitution.map = map.id
  and substitution.participant = participant.id
group by extract.log_id
)

, pre as (
select team.id as team
     , any_value(tournament.id) as tournament
     , any_value(round.id) as round
     , any_value(match.id) as match
     , map.id as map
     , coef.id as team_coefficient
     , case coef.variable
       when 'map_win'
       then (
         sum(case when team_a_is_red and team.id = match.team_a
           then red_score - blue_score
           else blue_score - red_score
         end) > 0
       )::int::decimal

       when 'map_win'
       then (
         sum(case when team_a_is_red and team.id = match.team_a
           then red_score - blue_score
           else blue_score - red_score
         end) <= 0
       )::int::decimal

       when 'round_wins'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_score
         else blue_score
       end)

       when 'round_losses'
       then sum(case when team_a_is_red and team.id = match.team_a
         then blue_score
         else red_score
       end)

       when 'caps'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_caps
         else blue_caps
       end)

       when 'first_caps'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_first_caps
         else blue_first_caps
       end)

       when 'kills'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_kills
         else blue_kills
       end)

       when 'deaths'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_deaths
         else blue_deaths
       end)

       when 'damage'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_damage
         else blue_damage
       end)

       when 'medic_deaths'
       then sum(case when team_a_is_red and team.id = match.team_a
         then (select sum(d) from unnest(red_medic_deaths) d)
         else (select sum(d) from unnest(blue_medic_deaths) d)
       end)

       when 'ubercharges'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_ubercharges
         else blue_ubercharges
       end)

       when 'drops'
       then sum(case when team_a_is_red and team.id = match.team_a
         then red_drops
         else blue_drops
       end)
       end
       as total
     , coef.coefficient
from extract
join team_side on team_side.log_id = extract.log_id
join map on extract.log_id in (map.log_id, map.golden_cap_log_id)
join match on match.id = map.match
join team on team.id in (match.team_a, match.team_b)
join round on round.id = match.round
join tournament on tournament.id = round.tournament
join scoring_model on scoring_model.id = tournament.scoring_model
join team_coefficient coef on coef.scoring_model = scoring_model.id
group by (team.id, map.id, coef.id)
)

select team
     , any_value(tournament) as tournament
     , round
     , match
     , map
     , team_coefficient
     , case when grouping(team_coefficient) = 1 then null else sum(total) end as total
     , sum(total * coefficient) as score
from pre
group by grouping sets
( (team, round, match, map, team_coefficient)
, (team, round, match, map)
, (team, round, match, team_coefficient)
, (team, round, match)
, (team, round, team_coefficient)
, (team, round)
, (team, team_coefficient)
, (team)
);

comment on materialized view team_performance is 'how much of a statistic has a team achieved';

commit;
