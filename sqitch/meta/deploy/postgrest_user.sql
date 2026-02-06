-- Deploy meta:postgrest_user to pg

begin;

create user postgrest noinherit password :password_postgrest;

commit;
