-- Deploy auth:friendship to pg

begin;

set search_path to auth;

create table friendship
( user_a text not null
, user_b text not null
, primary key (user_a, user_b)
, foreign key (user_a) references user
, foreign key (user_b) references user
);

comment on table friendship is 'graph of Steam friends';

commit;
