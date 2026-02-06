-- Revert fantasy:v0/permissions to pg

begin;

set search_path to fantasy_v0;

revoke usage on schema fantasy_v0 from fantasy_visitor;
revoke usage on schema fantasy_v0 from fantasy_manager;

commit;
