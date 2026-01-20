-- Deploy fantasy:team_coefficient to pg

begin;

set search_path to fantasy, public;

create table team_coefficient
( id             serial  not null
, scoring_model  int     not null
, team_statistic text    not null
, coefficient    decimal not null
, primary key (id)
, foreign key (scoring_model) references scoring_model
, foreign key (team_statistic) references team_statistic
, unique (scoring_model, team_statistic)
);

comment on table team_coefficient is '[ADM] how many points should each statistic give';

commit;
