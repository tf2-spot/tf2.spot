-- Deploy fantasy:schema to pg

BEGIN;

create schema fantasy;
comment on schema fantasy is 'schema for fantasy.tf2.spot data';

COMMIT;
