-- Deploy fantasy:match to pg

begin;

set search_path to fantasy, public;

create table match
( id         serial not null
, round      int    not null
, team_left  int    not null
, team_right int    not null
, primary key (id)
, foreign key (round) references round
, foreign key (team_left) references team
, foreign key (team_right) references team
);

comment on table match is '! match between two teams';

commit;
