-- Deploy fantasy:fantasy to pg

begin;

set search_path to fantasy, public;

create table fantasy
( id             serial not null
, tournament     int    not null
, manager        bigint not null
, name           text   not null
, initial_budget int    not null
, unique (tournament, manager)
, primary key (id)
, foreign key (tournament) references tournament
, foreign key (manager) references manager
);

comment on table fantasy.fantasy is 'fantasy roster in a tournament';

commit;
