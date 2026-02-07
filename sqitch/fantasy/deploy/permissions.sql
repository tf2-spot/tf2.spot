-- Deploy fantasy:permissions to pg

begin;

set search_path to fantasy;

grant fantasy_visitor to postgrest;
grant fantasy_manager to postgrest;

grant usage on schema fantasy to fantasy_admin;

grant select, insert, update, delete on scoring_model to fantasy_admin;
grant select on team_statistic to fantasy_admin;
grant select, insert, update, delete on team_coefficient to fantasy_admin;
grant select on player_statistic to fantasy_admin;
grant select, insert, update, delete on player_coefficient to fantasy_admin;

grant select on region to fantasy_admin;
grant select on composition to fantasy_admin;
grant select, insert, update on tournament to fantasy_admin;
grant select, insert, update, delete on round to fantasy_admin;

grant select on class to fantasy_admin;
grant select, insert, update on player to fantasy_admin;
grant select, insert, update, delete on team to fantasy_admin;
grant select, insert, update, delete on participant to fantasy_admin;
grant select on price_history to fantasy_admin;

grant select, insert, update, delete on fantasy.match to fantasy_admin;
grant select, insert, update, delete on map to fantasy_admin;
grant select, insert, update, delete on substitution to fantasy_admin;
grant select on team_performance to fantasy_admin;
grant select on player_performance to fantasy_admin;

grant select on logstf_document to fantasy_admin;

grant select, update on manager to fantasy_admin;
grant select on friendship to fantasy_admin;
grant select, update on fantasy to fantasy_admin;
grant select on contract to fantasy_admin;

commit;
