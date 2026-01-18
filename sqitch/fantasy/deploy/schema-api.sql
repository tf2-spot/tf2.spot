-- Deploy fantasy:schema-api to pg

begin;

create schema fantasy_api;

comment on schema fantasy_api is 'schema for views and procedures served by PostgREST';

commit;
