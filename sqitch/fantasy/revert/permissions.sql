-- Revert fantasy:permissions to pg

begin;

set search_path to fantasy;

revoke fantasy_visitor from postgrest;
revoke fantasy_manager from postgrest;

commit;
