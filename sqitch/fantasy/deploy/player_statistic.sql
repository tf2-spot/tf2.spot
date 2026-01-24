-- Deploy fantasy:player_statistic to pg

begin;

set search_path to fantasy, public;

create table player_statistic
( id          text not null
, short       text not null
, description text not null
, primary key (name)
);

comment on table player_statistic is 'static set of possible measurements of a player during a map';

commit;
