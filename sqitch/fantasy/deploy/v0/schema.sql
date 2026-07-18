-- Deploy fantasy:v0/schema to pg

begin;

create schema fantasy_v0;

comment on schema fantasy_v0 is 'schema for web API';

commit;
