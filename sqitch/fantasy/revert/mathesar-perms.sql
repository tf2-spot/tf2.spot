-- Revert fantasy:mathesar-perms from pg

BEGIN;

revoke select
on table fantasy.manager
       , fantasy.region
       , fantasy.tournament
from fantasy_admin;

revoke select
     , insert
     , update
     , delete
     , truncate
on table fantasy.manager
       , fantasy.region
       , fantasy.tournament
from mathesar;

revoke usage on schema fantasy from mathesar;

COMMIT;
