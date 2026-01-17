-- Deploy fantasy:multiplier to pg

begin;

set search_path to fantasy, public;

create table multiplier
( id            serial  not null
, scoring_model int     not null
, statistic     text    not null
, multiplier    decimal not null
, primary key (id)
, foreign key (scoring_model) references scoring_model
, foreign key (statistic) references statistic
);

commit;
