-- Revert fantasy:mathesar-perms from pg

begin;

set search_path to fantasy, public;

revoke select
on table manager
       , region
       , tournament
from fantasy_admin;

revoke select
     , insert
     , update
     , delete
     , truncate
on table manager
       , region
       , tournament
from mathesar;

revoke usage on schema fantasy from mathesar;

commit;
