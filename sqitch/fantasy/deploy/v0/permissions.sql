-- Deploy fantasy:v0/permissions to pg

begin;

set search_path to fantasy_v0;

grant usage on schema fantasy_v0 to fantasy_visitor;
grant usage on schema fantasy_v0 to fantasy_manager;

grant select, insert, update on me to fantasy_manager;

grant select on manager to fantasy_visitor;
grant select on manager to fantasy_manager;

commit;
