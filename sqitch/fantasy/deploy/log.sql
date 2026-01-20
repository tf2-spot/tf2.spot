-- Deploy fantasy:log to pg

begin;

set search_path to fantasy, public;

create table log
( log_id int not null
, map  int not null
, primary key (log_id)
, foreign key (map) references map
);

comment on table log is '! id of a log from logs.tf for a played map';

commit;
