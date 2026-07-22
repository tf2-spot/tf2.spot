-- Revert fantasy:role-janitor to pg

begin;

revoke select, update on fantasy.manager from fantasy_janitor;
revoke select on fantasy.map from fantasy_janitor;
revoke select, insert on fantasy.logstf_document from fantasy_janitor;
revoke maintain on fantasy.player_performance from fantasy_janitor;
revoke maintain on fantasy.team_performance from fantasy_janitor;
revoke usage on schema fantasy from fantasy_janitor;

drop role fantasy_janitor;

commit;
