-- Deploy fantasy:player_performance to pg

begin;

set search_path to fantasy;

-- create table player_performance
-- ( map              int not null
-- , player           text not null
-- , player_statistic text not null
-- , value            decimal not null
-- , primary key (map, player, player_statistic)
-- , foreign key (map) references map
-- , foreign key (player) references player
-- , foreign key (player_statistic) references player_statistic
-- );

create materialized view player_performance as
select 1;

comment on materialized view player_performance is 'how much of a statistic has a player achieved';

commit;
