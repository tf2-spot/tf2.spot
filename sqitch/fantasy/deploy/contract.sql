-- Deploy fantasy:contract to pg

begin;

set search_path to fantasy, public;

create table contract
( id             serial  not null
, team           int     not null
, participant    int     not null
, time           tsrange not null
, purchase_price int     not null
, sale_price     int
, exclude using gist
    ( team with =
    , participant with =
    , time with &&
    )
, primary key (id)
, foreign key (team) references team
, foreign key (participant) references participant
);

commit;
