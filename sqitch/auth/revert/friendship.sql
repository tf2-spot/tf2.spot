-- Revert auth:friendship to pg

begin;

set search_path to auth;

drop table friendship;

commit;
