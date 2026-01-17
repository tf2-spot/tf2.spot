-- Deploy fantasy:map to pg

begin;

set search_path to fantasy, public;

create table map
( id      serial not null
, match   int    not null
, primary key    (id)
, foreign key (match) references match
);

commit;
