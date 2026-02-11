-- Revert fantasy:v0/permissions to pg

begin;

set search_path to fantasy_v0;

revoke select, insert, update on me from fantasy_manager;

revoke select
on manager
 , tournament
 , composition
 , scoring_model
 , player_coefficient
 , player_statistic
 , team_coefficient
 , team_statistic
 , round
from fantasy_visitor, fantasy_manager;

revoke usage on schema fantasy_v0 from fantasy_visitor, fantasy_manager;


commit;
