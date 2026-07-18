-- Deploy fantasy:role-admin to pg

begin;

create user fantasy_admin noinherit password :password_fantasy_admin;

commit;
