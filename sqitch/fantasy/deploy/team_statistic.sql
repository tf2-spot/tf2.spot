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
damage,Damage (team),damage by the team
deaths,Deaths (team),deaths by the team
drops,Drops (team),übercharges dropped by the team's Medic
first_caps,Mid win,first middle points of a round won by the team
kills,Kills (team),kills by the team
map_loss,Map Loss,maps lost
map_win,Map Win,maps won
medic_deaths,Team Medic Deaths,deaths of the team's Medic
round_losses,Round loss,rounds lost
round_wins,Round win,rounds won
ubercharges,Übers (team),übercharges used by the team's Medic
\.

commit;
