-- Revert fantasy:v0/schema to pg

begin;

drop schema fantasy_v0;

commit;
