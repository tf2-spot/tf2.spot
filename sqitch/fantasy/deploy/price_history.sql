-- Deploy fantasy:price_history to pg

begin;

set search_path to fantasy;

create table price_history
( id          serial    not null
, participant int       not null
, price       int       not null
, until       timestamp not null
, primary key (id)
, foreign key (participant) references participant
);

comment on table price_history is 'history of prices for a participant';

create function trigger_price_history()
returns trigger
language plpgsql
as $$
begin
    insert into fantasy.price_history (participant, price, until)
    values (NEW.id, OLD.price, now());
    
    return new;
end;
$$;

create trigger trigger_price_history
after update of price on participant
for each row
execute function trigger_price_history();

commit;
