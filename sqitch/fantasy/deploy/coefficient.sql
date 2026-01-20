-- Deploy fantasy:coefficient to pg

begin;

set search_path to fantasy, public;

create table coefficient
( id            serial  not null
, scoring_model int     not null
, statistic     text    not null
, coefficient   decimal not null
, primary key (id)
, foreign key (scoring_model) references scoring_model
, foreign key (statistic) references statistic
, unique (scoring_model, statistic)
);

comment on table coefficient is '! how many points should each statistic give';

commit;
