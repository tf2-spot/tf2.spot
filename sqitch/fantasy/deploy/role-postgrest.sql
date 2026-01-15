-- Deploy fantasy:role-postgrest to pg

BEGIN;

create user fantasy_postgrest noinherit password :password_fantasy_postgrest;

COMMIT;
