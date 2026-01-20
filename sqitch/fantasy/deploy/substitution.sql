-- Deploy fantasy:substitution to pg

begin;

set search_path to fantasy, public;

create table substitution
( id          serial not null
, map         int    not null
, participant int    not null
, substitute  text   not null
, primary key (id)
, foreign key (map) references map
, foreign key (participant) references participant
, foreign key (substitute) references player
);

comment on table substitution is '! which player was used as substitute during a map';

commit;
