-- Revert auth:user to pg

begin;

set search_path to auth;

drop table user;

commit;
