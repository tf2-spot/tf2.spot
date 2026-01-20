-- Deploy fantasy:class to pg

begin;

set search_path to fantasy, public;

create table class
( name text not null
, primary key (name)
);

comment on table class is 'static set of TF2 classes';

insert into class (name) values
('scout'),
('soldier'),
('pyro'),
('demoman'),
('heavy'),
('engineer'),
('sniper'),
('medic'),
('spy');

commit;
