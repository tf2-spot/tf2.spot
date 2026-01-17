-- Deploy fantasy:region to pg

begin;

set search_path to fantasy, public;

create table region
( name text not null
, primary key (name)
);

comment on table region is 'static set of regions where TF2 is played';

insert into region (name) values
('Europe'),
('Asia'),
('Oceania'),
('North America'),
('South America');

commit;
