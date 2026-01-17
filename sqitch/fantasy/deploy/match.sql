-- Deploy fantasy:match to pg

begin;

set search_path to fantasy, public;

create table match
( id       serial not null
, round    int    not null
, team_blu int    not null
, team_red int    not null
, primary key (id)
, foreign key (round) references round
, foreign key (team_blu) references team
, foreign key (team_red) references team
);

commit;
