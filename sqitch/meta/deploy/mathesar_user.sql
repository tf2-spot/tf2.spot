-- Deploy meta:mathesar_user to pg

BEGIN;

create user mathesar login password :password_mathesar;

grant connect, create on database postgres to mathesar;

COMMIT;
