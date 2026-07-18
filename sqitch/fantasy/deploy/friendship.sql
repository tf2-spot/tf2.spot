-- Deploy fantasy:friendship to pg

begin;

set search_path to fantasy;

create table friendship
( manager_a text not null
, manager_b text not null
, primary key (manager_a, manager_b)
, foreign key (manager_a) references manager
, foreign key (manager_b) references manager
);

comment on table friendship is 'graph of Steam friends';

commit;
