-- Deploy fantasy:role-janitor to pg

begin;

create user fantasy_janitor noinherit;

grant usage on schema fantasy to fantasy_janitor;
grant select, update on fantasy.manager to fantasy_janitor;
grant select on fantasy.map to fantasy_janitor;
grant select, insert on fantasy.logstf_document to fantasy_janitor;
grant maintain on fantasy.player_performance to fantasy_janitor;
grant maintain on fantasy.team_performance to fantasy_janitor;

commit;
