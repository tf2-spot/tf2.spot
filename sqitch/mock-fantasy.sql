begin;

set search_path to fantasy;

insert into manager values ('76561197990142005', 'beater');
insert into manager values ('76561198020242938', 'twiikuu');

insert into friendship values ('76561197990142005', '76561198020242938');

insert into scoring_model values (1, 'V1');

insert into multiplier
select row_number() over ()
     , 1
     , name
     , 1 / (random() * random())
from statistic;

insert into tournament values (1, 'poLANd', null, 'Europe', 1, now(), now() + interval '2 week', 1000, 10);

insert into round
select row_number() over ()
     , 1
     , generate_series::text
     , generate_series
from generate_series(now(), now() + interval '2 week', '1 day');

copy real_team (tournament, name) from stdin with delimiter ',';
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
select real_team.name::text || ' ' || class.name as steam_id
     , real_team.name::text || ' ' || class.name as name
from real_team
join class on true;

insert into participant
select row_number() over ()
     , 1 as tournament
     , real_team.name::text || ' ' || class.name as player
     , id as real_team
     , class.name as main_class
     , 1 as price
from real_team
join class on true;

insert into match
select row_number() over ()
     , round_id
     , min(real_team_id)
     , max(real_team_id)
from (
     select round.id as round_id
          , real_team.id as real_team_id
          , (row_number() over (order by round.id, random()) + 1) / 2 as match_num
     from round
     join real_team on true
)
group by round_id, match_num;

insert into map
select row_number() over ()
     , id
from match
join (values (1), (2)) on true;

insert into performance
select map.id
     , participant.id
     , statistic.name
     , 1 / (random() * random())
from map
join match on map.match = match.id
join real_team on match.team_blu = real_team.id or match.team_red = real_team.id
join participant on real_team.id = participant.real_team
join statistic on true;

commit;
