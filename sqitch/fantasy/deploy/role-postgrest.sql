-- Deploy fantasy:role-postgrest to pg

begin;

create user fantasy_postgrest noinherit password :password_fantasy_postgrest;

commit;
