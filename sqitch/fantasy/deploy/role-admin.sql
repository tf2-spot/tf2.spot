-- Deploy fantasy:role-admin to pg

BEGIN;

create user fantasy_admin password :password_fantasy_admin;

COMMIT;
