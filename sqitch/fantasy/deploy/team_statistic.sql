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

copy team_statistic (id, short, description) from stdin with delimiter ',';
caps,Captures (team),points captured by the team
charges,Übers (team),übercharges used by the team's Medic
damage,Damage (team),damage by the team
deaths,Deaths (team),deaths by the team
drops,Drops (team),übercharges dropped by the team's Medic
firstcaps,Mids (team),first middle point of a round won by the team
kills,Kills (team),kills by the team
lose,Lose,lost the map
medic_deaths,Medic Deaths (team),friendly Medic deaths
round_losses,Round loss,lost a round
round_wins,Round win,won a round
win,Win,won the map
\.

commit;
