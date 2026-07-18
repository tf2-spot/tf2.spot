-- Revert fantasy:permissions to pg

begin;

set search_path to fantasy;

revoke fantasy_visitor from postgrest;
revoke fantasy_manager from postgrest;

revoke select, insert, update, delete on scoring_model from fantasy_admin;
revoke select on team_statistic from fantasy_admin;
revoke select, insert, update, delete on team_coefficient from fantasy_admin;
revoke select on player_statistic from fantasy_admin;
revoke select, insert, update, delete on player_coefficient from fantasy_admin;

revoke select on region from fantasy_admin;
revoke select on composition from fantasy_admin;
revoke select, insert, update on tournament from fantasy_admin;
revoke select, insert, update, delete on round from fantasy_admin;

revoke select on class from fantasy_admin;
revoke select, insert, update on player from fantasy_admin;
revoke select, insert, update, delete on team from fantasy_admin;
revoke select, insert, update, delete on participant from fantasy_admin;
revoke select on price_history from fantasy_admin;

revoke select, insert, update, delete on fantasy.match from fantasy_admin;
revoke select, insert, update, delete on map from fantasy_admin;
revoke select, insert, update, delete on substitution from fantasy_admin;
revoke select on team_performance from fantasy_admin;
revoke select on player_performance from fantasy_admin;

revoke select on logstf_document from fantasy_admin;

revoke select, update on manager from fantasy_admin;
revoke select on friendship from fantasy_admin;
revoke select, update on fantasy from fantasy_admin;
revoke select on contract from fantasy_admin;

revoke usage on schema fantasy from fantasy_admin;

commit;
