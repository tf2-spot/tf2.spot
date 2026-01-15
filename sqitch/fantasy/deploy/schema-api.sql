-- Deploy fantasy:schema-api to pg

BEGIN;

create schema fantasy_api;
comment on schema fantasy_api is 'schema for views and procedures served by PostgREST';

COMMIT;
