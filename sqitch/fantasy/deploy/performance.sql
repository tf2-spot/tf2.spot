-- Deploy fantasy:performance to pg

begin;

set search_path to fantasy, public;

create table performance
( map       int     not null
, player    text    not null
, statistic text    not null
, value     decimal not null
, primary key (map, player, statistic)
, foreign key (map) references map
, foreign key (player) references player
, foreign key (statistic) references statistic
);

comment on table performance is 'how much of a statistic has a player achieved during one map';

commit;
