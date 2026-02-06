-- Deploy fantasy:tournament to pg

begin;

set search_path to fantasy;

create table tournament
( id                   serial    not null
, name                 text      not null
, logo                 mathesar_types.uri
, region               text      not null
, scoring_model        int       not null
, composition          int       not null
, start_time           timestamp not null
, end_time             timestamp
, initial_budget       int       not null
, transactions         int       not null
, max_from_single_team int       not null
, primary key (id)
, foreign key (region) references region
, foreign key (scoring_model) references scoring_model
, foreign key (composition) references composition
);

comment on table tournament is '[ADM] event, cup or season of organized matches';

commit;
