-- Deploy fantasy:performance to pg

begin;

set search_path to fantasy, public;

create table performance
( map int not null
, participant int not null
, statistic text not null
, value decimal not null
, primary key (map, participant, statistic)
, foreign key (map) references map
, foreign key (participant) references participant
, foreign key (statistic) references statistic
);

commit;
