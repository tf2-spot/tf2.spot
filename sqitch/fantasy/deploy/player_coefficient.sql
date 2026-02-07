-- Deploy fantasy:player_coefficient to pg

begin;

set search_path to fantasy;

create table player_coefficient
( id                serial not null
, scoring_model     int not null
, variable          text not null
, divide_by         text
, highest           boolean not null
, lowest            boolean not null
, score_coefficient decimal not null
, primary key (id)
, foreign key (scoring_model) references scoring_model
, foreign key (variable) references player_statistic
, foreign key (divide_by) references player_statistic
, check (not highest or not lowest)
);

comment on table player_coefficient is '[ADM] how many points should be given for a specific term';

comment on column player_coefficient.variable is 'use the sum of this statistic';
comment on column player_coefficient.divide_by is 'create a ratio using another statistic (e.g. kills per death, damage per minute)';
comment on column player_coefficient.highest is 'attribute 1×score when the result is the highest of all players this map';
comment on column player_coefficient.lowest is 'attribute 1×score when the result is the lowest of all players this map';
comment on column player_coefficient.score_coefficient is 'multiplied with the result to get scored points';

commit;
