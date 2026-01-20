-- Deploy fantasy:scoring_model to pg

begin;

set search_path to fantasy, public;

create table scoring_model
( id   serial not null
, name text
, primary key (id)
);

comment on table scoring_model is '[ADM] how all performances will be scored during a tournament';

commit;
