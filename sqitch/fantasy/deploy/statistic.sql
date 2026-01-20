-- Deploy fantasy:statistic to pg

begin;

set search_path to fantasy, public;

create table statistic
( name text not null
, description text not null
, primary key (name)
);

comment on table statistic is 'static set of possible measurements of a player during a map';

insert into statistic values
('win',              'Won the map'),
('win-diff',         'Point difference when winning'),
('kills',             'Killed an enemy'),
('medic-kill',       'Killed an enemy medic'),
('kills_as_medic',    'Killed as a medic'),
('deaths',            'Died'),
('dpm',              'Damage per minute'),
('ubers',             'Ubercharge used'),
('drops',        'Ubercharge dropped'),
('team-medic-death', 'Friendly Medic died'),
('top-kill',         'Has the highest number of kills'),
('top-damage',       'Has the highest number of damage'),
('top-kdr',          'Has the highest kill to death ratio'),
('airshots',          'Has hit an enemy in the air with a projectile'),
('assists',           ''),
('backstabs',         ''),
    ('headshots',    '');

commit;
