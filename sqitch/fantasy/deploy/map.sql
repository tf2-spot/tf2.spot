-- Deploy fantasy:map to pg

begin;

set search_path to fantasy, public;

create table map
( id                serial not null
, match             int    not null
, name              text   not null
, log_id            int    not null
, golden_cap_log_id int    not null
, primary key (id)
, foreign key (match) references match
);

comment on table map is '[ADM] map played as part of a match';

commit;
