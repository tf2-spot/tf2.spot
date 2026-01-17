-- Deploy fantasy:manager to pg

begin;

set search_path to fantasy, public;

create table manager
( steam_id text not null
, name     text not null
, avatar   mathesar_types.uri
, muted    bool not null default false
, primary key (steam_id)
);

comment on table manager is 'person taking part in the game of Fantasy TF2';

commit;
