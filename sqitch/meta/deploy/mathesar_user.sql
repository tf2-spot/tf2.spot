-- Deploy meta:mathesar_user to pg

begin;

create user mathesar login password :password_mathesar;

grant connect, create on database postgres to mathesar;

commit;
