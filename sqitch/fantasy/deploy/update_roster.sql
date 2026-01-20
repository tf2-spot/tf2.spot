-- Deploy fantasy:update_roster to pg

begin;

set search_path to fantasy, public;

create function update_roster(fantasy_id int, desired_roster int[])
returns void
language plpgsql
strict
as $$
declare
    now timestamp with time zone = now();
begin
    if not exists (select 1 from fantasy where id = fantasy_id) then
        raise exception 'Fantasy team does not exist';
    end if;

    if exists (
        select 1
        from tournament
        join fantasy on fantasy.tournament = tournament.id
        where fantasy_id = fantasy.id
        and end_time < now
    ) then
        raise exception 'Tournament is over';
    end if;

    update contract
    set time = tsrange(lower(time), now::timestamp)
      , sale_price = p.price
    from participant p
    where p.id = participant
    and upper(time) is null
    and not (participant = any(desired_roster));

    insert into contract
    select nextval('contract_id_seq')
         , fantasy_id
         , participant.id
         , tsrange(now::timestamp, null)
         , participant.price
         , null
    from unnest(desired_roster)
    join participant on participant.id = unnest
    on conflict do nothing;

    if exists (
        select 1
        from contract
        join fantasy on fantasy.id = contract.fantasy
        join tournament on tournament.id = fantasy.tournament
        where fantasy = fantasy_id
        group by (tournament.id)
        having count(upper(time)) > tournament.transactions
    ) then
        raise exception 'Exceeded amount of transactions available';
    end if;

    if exists (
        select 1
        from contract
        join fantasy on fantasy.id = contract.fantasy
        where contract.fantasy = fantasy_id
        group by (fantasy.id)
        having fantasy.initial_budget + sum(coalesce(sale_price, 0) - purchase_price) < 0
    ) then
        raise exception 'Exceeded budget spending';
    end if;

    -- TODO
    if exists (
        select 1
        from contract
        join participant on participant.id = contract.participant
        where fantasy = fantasy_id
        and upper(time) is null
        having array_agg(main_class order by main_class)
            <> '{Demoman, Medic, Scout, Scout, Soldier, Soldier}'
    ) then
        raise exception 'Team composition requires 2 scouts, 2 soldiers, 1 demoman and 1 medic';
    end if;

    if exists (
        select 1
        from contract
        join participant on participant.id = contract.participant
        where fantasy = fantasy_id
        and upper(time) is null
        group by (fantasy, participant.team)
        having count(participant.id) > 2
    ) then
        raise exception 'Fantasy team has a limit of 2 players from any team';
    end if;
end;
$$;

commit;
