-- Deploy fantasy:participant to pg

begin;

set search_path to fantasy, public;

create table participant
( id         serial not null
, tournament int    not null
, player     text   not null
, team       int    not null
, main_class text   not null
, price      int    not null
, unique (tournament, player)
, primary key (id)
, foreign key (tournament) references tournament
, foreign key (player) references player
, foreign key (team) references team
, foreign key (main_class) references class
);

comment on table fantasy.participant is '[ADM] real player participating in a tournament with a team';

commit;
