-- Deploy fantasy:team_statistic to pg

begin;

set search_path to fantasy;

create table team_statistic
( id          text not null
, short       text not null
, description text not null
, primary key (id)
);

comment on table team_statistic is 'static set of possible measurements of a team during a map';

commit;
