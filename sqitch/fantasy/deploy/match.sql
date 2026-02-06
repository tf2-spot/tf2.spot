-- Deploy fantasy:match to pg

begin;

set search_path to fantasy;

create table match
( id     serial not null
, round  int    not null
, team_a int    not null
, team_b int    not null
, primary key (id)
, foreign key (round) references round
, foreign key (team_a) references team
, foreign key (team_b) references team
);

comment on table match is '[ADM] match between two teams';

commit;
