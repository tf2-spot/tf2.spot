-- Deploy fantasy:v0/permissions to pg

begin;

set search_path to fantasy_v0;

grant usage on schema fantasy_v0 to fantasy_visitor, fantasy_manager;

grant select, insert, update on me to fantasy_manager;
grant select, insert, update on my_fantasy to fantasy_manager;

grant select
on manager
 , tournament
 , composition
 , scoring_model
 , player_coefficient
 , player_statistic
 , team_coefficient
 , team_statistic
 , round
 , team
 , participant
 , player
 , player_performance
 , fantasy
 , contract
 , contract_value
to fantasy_visitor, fantasy_manager;

commit;
