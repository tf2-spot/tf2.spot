-- Deploy fantasy:team to pg

begin;

set search_path to fantasy;

create table team
( id         serial not null
, tournament int    not null
, name       text   not null
, tag        text
, logo       mathesar_types.uri
, primary key (id)
, foreign key (tournament) references tournament
);

comment on table team is '[ADM] real team participating in a tournament';

commit;
