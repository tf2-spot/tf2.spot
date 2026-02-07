-- Deploy fantasy:team_performance to pg

begin;

set search_path to fantasy;

-- create table team_performance
-- ( map            int not null
-- , team           int not null
-- , team_statistic text not null
-- , value          decimal not null
-- , primary key (map, team, team_statistic)
-- , foreign key (map) references map
-- , foreign key (team) references team
-- , foreign key (team_statistic) references team_statistic
-- );

create materialized view team_performance as
select 1;

comment on view team_performance is 'how much of a statistic has a team achieved';

commit;
