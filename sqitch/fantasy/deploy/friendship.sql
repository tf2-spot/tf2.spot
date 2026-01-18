-- Deploy fantasy:friendship to pg

begin;

set search_path to fantasy, public;

create table friendship
( manager_left  text not null
, manager_right text not null
, primary key (manager_left, manager_right)
, foreign key (manager_left) references manager
, foreign key (manager_right) references manager
);

comment on table friendship is 'graph of Steam friends';

commit;
