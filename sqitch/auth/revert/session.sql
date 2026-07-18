-- Revert auth:session to pg

begin;

set search_path to auth;

drop table session;

commit;
