-- Deploy fantasy:price_history to pg

begin;

set search_path to fantasy, public;

create table price_history
( id serial not null
, participant int not null
, price int not null
, until timestamp not null
, primary key (id)
, foreign key (participant) references participant
);

comment on table price_history is 'history of prices for a participant';

commit;
