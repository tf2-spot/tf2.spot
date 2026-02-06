-- Deploy fantasy:composition to pg

begin;

set search_path to fantasy;

create table composition
( id       serial not null
, name     text   not null
, scout    int    not null default 0
, soldier  int    not null default 0
, pyro     int    not null default 0
, demoman  int    not null default 0
, heavy    int    not null default 0
, engineer int    not null default 0
, medic    int    not null default 0
, sniper   int    not null default 0
, spy      int    not null default 0
, primary key (id)
);

comment on table composition is '[ADM] how many of each class should there be in a team';

insert into composition (name, scout, soldier, demoman, medic) values ('6v6', 2, 2, 1, 1);
insert into composition values (nextval('composition_id_seq'), 'Highlander', 1, 1, 1, 1, 1, 1, 1, 1, 1);
insert into composition (name, soldier, medic) values ('Ultiduo', 1, 1);

commit;
