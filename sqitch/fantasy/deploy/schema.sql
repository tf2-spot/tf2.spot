-- Deploy fantasy:schema to pg

begin;

create schema fantasy;

comment on schema fantasy is 'schema for data';

commit;
