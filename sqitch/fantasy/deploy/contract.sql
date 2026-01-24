-- Deploy fantasy:contract to pg

begin;

set search_path to fantasy, public;

create table contract
( id             serial  not null
, fantasy        int     not null
, participant    int     not null
, time           tsrange not null
, purchase_price int     not null
, sale_price     int
, primary key (id)
, foreign key (fantasy) references fantasy
, foreign key (participant) references participant
, exclude using gist
    ( fantasy with =
    , participant with =
    , time with &&
    )
, check ((upper(time) is null) = (sale_price is null))
);

comment on table contract is 'roster activity for a fantasy team';

commit;
