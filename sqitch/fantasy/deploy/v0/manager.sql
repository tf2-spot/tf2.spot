-- Deploy fantasy:v0/manager to pg

begin;

set search_path to fantasy_v0;

create view manager as select * from fantasy.manager; 

commit;
