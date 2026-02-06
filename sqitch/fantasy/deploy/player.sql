-- Deploy fantasy:player to pg

begin;

set search_path to fantasy;

create table player
( steam_id text not null
, name     text not null
, avatar   mathesar_types.uri
, primary key (steam_id)
);

comment on table player is '[ADM] real player';

commit;
