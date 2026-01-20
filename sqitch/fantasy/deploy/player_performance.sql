-- Deploy fantasy:player_performance to pg

begin;

set search_path to fantasy, public;

create table player_performance
( log              int     not null
, player           bigint  not null
, player_statistic text    not null
, value            decimal not null
, primary key (log, player, player_statistic)
, foreign key (log) references log
, foreign key (player) references player
, foreign key (player_statistic) references player_statistic
);

comment on table player_performance is 'how much of a statistic has a player achieved';

commit;
