-- Revert auth:schema to pg

begin;

drop schema auth;

commit;
