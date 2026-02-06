-- Deploy fantasy:permissions to pg

begin;

set search_path to fantasy;

grant fantasy_visitor to postgrest;
grant fantasy_manager to postgrest;

commit;
