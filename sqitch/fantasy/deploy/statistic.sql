-- Deploy fantasy:statistic to pg

begin;

set search_path to fantasy, public;

create table statistic
( id serial not null
, short text not null
, description text not null
, primary key (id)
);

insert into statistic (short, description) values
('win',     'Won the map'),
('windiff', 'Point difference when winning');

commit;
