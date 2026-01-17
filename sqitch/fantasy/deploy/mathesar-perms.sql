-- Deploy fantasy:mathesar-perms to pg

begin;

set search_path to fantasy, public;

grant usage on schema fantasy to mathesar;

grant select
    , insert
    , update
    , delete
    , truncate
on table manager
       , region
       , tournament
to mathesar;

grant select
on table manager
       , region
       , tournament
to fantasy_admin;

commit;
