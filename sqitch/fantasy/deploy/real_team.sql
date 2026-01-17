-- Deploy fantasy:real_team to pg

begin;

set search_path to fantasy, public;

create table real_team
( id         serial not null
, tournament int    not null
, name       text   not null
, tag        text
, logo       mathesar_types.uri
, primary key (id)
, foreign key (tournament) references tournament
);

comment on table real_team is 'real team participating in a tournament';

commit;
