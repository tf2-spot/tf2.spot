-- Deploy fantasy:manager to pg
-- requires: schema

BEGIN;

create table fantasy.manager
( steam_id text not null
, name     text not null
, avatar   text not null
, muted    bool not null default false
, primary key (steam_id)
);

COMMIT;
