-- Deploy fantasy:region to pg
-- requires: schema

BEGIN;

create table fantasy.region
( name text not null
, primary key (name)
);

insert into fantasy.region (name) values
('Europe'),
('Asia'),
('Oceania'),
('North America'),
('South America');

COMMIT;
