begin;

insert into fantasy.manager values ('76561197990142005', 'beater');
insert into fantasy.manager values ('76561198020242938', 'twiikuu');

insert into fantasy.friendship values ('76561197990142005', '76561198020242938');

insert into fantasy.tournament values (1, 'i63', null, 'Europe', 1, '2020-01-01', null, 1000, 10);

insert into fantasy.real_team values (1, 1, 'Se7en');

insert into fantasy.player values ('76561197963314359', 'Kaidus');

insert into fantasy.participant values (1, 1, '76561197963314359', 1, 'Demoman', 100);

commit;
