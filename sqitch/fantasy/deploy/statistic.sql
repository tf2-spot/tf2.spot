-- Deploy fantasy:statistic to pg

begin;

set search_path to fantasy, public;

create table statistic
( name text not null
, description text not null
, primary key (name)
);

insert into statistic values
('win',     'Won the map'),
('win-diff', 'Point difference when winning'),
('kill', 'Killed an enemy'),
('medic-kill', 'Killed an enemy medic'),
('kill-as-medic', 'Killed as a medic'),
('death', 'Died'),
('dpm', 'Damage per minute'),
('uber', 'Ubercharge used'),
('uber-drop', 'Ubercharge dropped'),
('team-medic-death', 'Friendly Medic died'),
('top-kill', 'Has the highest number of kills'),
('top-damage', 'Has the highest number of damage'),
('top-kdr', 'Has the highest kill to death ratio'),
('airshot', 'Has hit an enemy in the air with a projectile'),
('assist', ''),
('backstab', ''),
('headshot-kill', '');

commit;
