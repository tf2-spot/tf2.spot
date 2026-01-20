-- Deploy fantasy:player_coefficient to pg

begin;

set search_path to fantasy, public;

create table player_coefficient
( id               serial  not null
, scoring_model    int     not null
, player_statistic text    not null
, coefficient      decimal not null
, primary key (id)
, foreign key (scoring_model) references scoring_model
, foreign key (player_statistic) references player_statistic
, unique (scoring_model, player_statistic)
);

comment on table player_coefficient is '[ADM] how many points should each statistic give';

commit;
