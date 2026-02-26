-- Deploy fantasy:player_performance to pg

begin;

set search_path to fantasy;

create materialized view player_performance as
with pre as (
  select participant.id as participant
       , any_value(tournament.id) as tournament
       , any_value(round.id) as round
       , any_value(match.id) as match
       , map.id as map
       , coef.id as player_coefficient
       , case when highest and divide_by is not null
              then ( sum(var.value) / coalesce(nullif(sum(div.value), 0), 1)
                     = max(sum(var.value) / coalesce(nullif(sum(div.value), 0), 1)) over (partition by map.id, coef.id)
                   )::int::decimal

              when lowest and divide_by is not null
              then ( sum(var.value) / coalesce(nullif(sum(div.value), 0), 1)
                     = min(sum(var.value) / coalesce(nullif(sum(div.value), 0), 1)) over (partition by map.id, coef.id)
                   )::int::decimal

              when highest
              then ( sum(var.value) = max(sum(var.value)) over (partition by map.id, coef.id)
                   )::int::decimal

              when lowest
              then ( sum(var.value) = min(sum(var.value)) over (partition by map.id, coef.id)
                   )::int::decimal

              when divide_by is not null
              then sum(var.value) / coalesce(nullif(sum(div.value), 0), 1)

              else sum(var.value)
         end as total
       , coef.coefficient
       , divide_by is not null and not highest and not lowest as is_average
       , sum(var.value) as variable
       , sum(div.value) as divide_by

  from map
  join match on match.id = map.match
  join round on round.id = match.round
  join tournament on tournament.id = round.tournament
  join scoring_model on scoring_model.id = tournament.scoring_model
  join player_coefficient coef on coef.scoring_model = scoring_model.id

  join team on team.id in (match.team_a, match.team_b)
  join participant on participant.team = team.id
  left join substitution on substitution.map = map.id and substitution.participant = participant.id
  
  left join extract_player_stats var
    on var.log_id in (map.log_id, map.golden_cap_log_id)
    and var.steam_id in (participant.player, substitution.substitute)
    and var.statistic = coef.variable
  
  left join extract_player_stats div
    on div.log_id in (map.log_id, map.golden_cap_log_id)
    and div.steam_id in (participant.player, substitution.substitute)
    and div.statistic = coef.divide_by

  group by (map.id, coef.id, participant.id)
)

select participant
     , any_value(tournament) as tournament
     , round
     , match
     , map
     , player_coefficient
     , sum(variable) as variable
     , sum(divide_by) as divide_by
     , case when grouping(player_coefficient) = 1 then null
            when any_value(is_average) then sum(variable)/coalesce(nullif(sum(divide_by), 0), 1)
            else sum(total)
       end as total
     , sum(total * coefficient) as score
from pre
group by grouping sets
( (participant, round, match, map, player_coefficient)
, (participant, round, match, map)
, (participant, round, match, player_coefficient)
, (participant, round, match)
, (participant, round, player_coefficient)
, (participant, round)
, (participant, player_coefficient)
, (participant)
);

comment on materialized view player_performance is 'how much of a statistic has a player achieved';

commit;
