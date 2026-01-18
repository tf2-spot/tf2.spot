begin;

set search_path to fantasy;

insert into manager values ('76561197990142005', 'beater');
insert into manager values ('76561198020242938', 'twiikuu');

insert into friendship values ('76561197990142005', '76561198020242938');

insert into scoring_model values (1, 'V1');

insert into coefficient
select nextval('coefficient_id_seq')
     , 1
     , name
     , 1 / (random() * random())
from statistic;

insert into tournament values (1, 'poLANd', null, 'Europe', 1, now(), now() + interval '2 week', 1000, 10);

insert into round
select nextval('round_id_seq')
     , 1
     , generate_series::text
     , generate_series
from generate_series(now(), now() + interval '5 day', '1 day');

copy team (tournament, name) from stdin with delimiter ',';
1,Allen's Workshop
1,Bloking Hazard
1,DIRTY MAGGOTS
1,Fjord Gaming
1,/for fence
1,froyotech
1,mak's team
1,MANDEM
1,Moneyballs
1,The AMS team
1,VNC
1,Witness Gaming EU
\.

insert into player
select team.name::text || ' ' || class.name as steam_id
     , team.name::text || ' ' || class.name as name
from team
join class on true;

insert into participant
select nextval('participant_id_seq')
     , 1 as tournament
     , team.name::text || ' ' || class.name as player
     , id as team
     , class.name as main_class
     , 1 as price
from team
join class on true;

insert into match
select nextval('match_id_seq')
     , round_id
     , min(team_id)
     , max(team_id)
from (
     select round.id as round_id
          , team.id as team_id
          , (row_number() over (order by round.id, random()) + 1) / 2 as match_num
     from round
     join team on true
)
group by round_id, match_num;

insert into map
select nextval('map_id_seq')
     , id
     , 'cp_badlands'
from match
join (values (1), (2)) on true;

insert into performance
select map.id
     , participant.id
     , statistic.name
     , 1 / (random() * random())
from map
join match on map.match = match.id
join team on match.team_left = team.id or match.team_right = team.id
join participant on team.id = participant.team
join statistic on true;

commit;
