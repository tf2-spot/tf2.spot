-- Deploy fantasy:round to pg

begin;

set search_path to fantasy;

create table round
( id         serial not null
, tournament int    not null
, name       text   not null
, time       timestamp
, primary key (id)
, foreign key (tournament) references tournament
);

comment on table round is '[ADM] matches that logically happen at the same time during a tournament';

commit;
