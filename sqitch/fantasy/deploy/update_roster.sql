-- Deploy fantasy:update_roster to pg

begin;

set search_path to fantasy;

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

    insert into contract (fantasy, participant, time, purchase_price)
    select fantasy_id
         , participant.id
         , tsrange(now::timestamp, null)
         , participant.price
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

    if not exists (
        select 1
        from contract
        join participant on participant.id = contract.participant
        join tournament on tournament.id = participant.tournament
        join composition on composition.id = tournament.composition
        where fantasy = fantasy_id
        and upper(time) is null
        having max(composition.scout) = count(1) filter (where main_class = 'scout')
        and max(composition.soldier)  = count(1) filter (where main_class = 'soldier')
        and max(composition.pyro)     = count(1) filter (where main_class = 'pyro')
        and max(composition.demoman)  = count(1) filter (where main_class = 'demoman')
        and max(composition.heavy)    = count(1) filter (where main_class = 'heavy')
        and max(composition.engineer) = count(1) filter (where main_class = 'engineer')
        and max(composition.medic)    = count(1) filter (where main_class = 'medic')
        and max(composition.sniper)   = count(1) filter (where main_class = 'sniper')
        and max(composition.spy)      = count(1) filter (where main_class = 'spy')
    ) then
        raise exception 'Invalid class composition';
    end if;

    if exists (
        select 1
        from contract
        join participant on participant.id = contract.participant
        join tournament on tournament.id = participant.tournament
        where fantasy = fantasy_id
        and upper(time) is null
        group by (fantasy, participant.team)
        having count(participant.id) > max(tournament.max_from_single_team)
    ) then
        raise exception 'Exceeded amount of players from a single team';
    end if;
end;
$$;

commit;
