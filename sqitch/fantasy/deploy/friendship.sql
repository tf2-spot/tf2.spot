-- Deploy fantasy:friendship to pg

begin;

set search_path to fantasy, public;

create table friendship
( left_manager  text not null
, right_manager text not null
, primary key (left_manager, right_manager)
, foreign key (left_manager) references manager
, foreign key (right_manager) references manager
);

comment on table friendship is 'graph of Steam friends';

commit;
