-- Deploy fantasy:substitution to pg

begin;

set search_path to fantasy;

create table substitution
( id          serial not null
, map         int    not null
, participant int    not null
, substitute  text   not null
, primary key (id)
, foreign key (map) references map
, foreign key (participant) references participant
, foreign key (substitute) references player
, unique (map, participant)
, unique (map, substitute)
-- check map -> match -> { team left / team right } = participant -> team
);

comment on table substitution is '[ADM] which player was used as substitute during a map';

commit;
