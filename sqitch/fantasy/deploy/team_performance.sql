-- Deploy fantasy:team_performance to pg

begin;

set search_path to fantasy, public;

create table team_performance
( log            int     not null
, team           int not null
, team_statistic text    not null
, value          decimal not null
, primary key (log, team, team_statistic)
, foreign key (log) references log
, foreign key (team) references team
, foreign key (team_statistic) references team_statistic
);

comment on table team_performance is 'how much of a statistic has a team achieved';

commit;
