-- Deploy fantasy:tournament to pg
-- requires: schema region

BEGIN;

create table fantasy.tournament
( slug           text      not null
, name           text      not null
, region         text      not null references fantasy.region (name)
, start_time     timestamp not null
, end_time       timestamp
, initial_budget int       not null
, transactions   int       not null
, primary key (slug)
);

COMMIT;
