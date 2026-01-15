-- Deploy fantasy:mathesar-perms to pg
-- requires: meta:@v1 schema manager region tournament role-admin

BEGIN;

grant usage on schema fantasy to mathesar;

grant select
    , insert
    , update
    , delete
    , truncate
on table fantasy.manager
       , fantasy.region
       , fantasy.tournament
to mathesar;

grant select
on table fantasy.manager
       , fantasy.region
       , fantasy.tournament
to fantasy_admin;

COMMIT;
