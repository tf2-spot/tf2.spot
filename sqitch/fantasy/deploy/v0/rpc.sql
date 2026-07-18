-- Deploy fantasy:v0/rpc to pg

begin;

set search_path to fantasy_v0;

create function update_roster(fantasy_id int, desired_roster int[])
returns void
language plpgsql
strict
security definer
as $$
begin
    if not exists (
        select 1
        from fantasy.fantasy
        where id = fantasy_id
        and manager = current_setting('request.jwt.claims', true)::json->>'manager_id'
    ) then
        raise exception 'Not authorized';
    end if;

    perform fantasy.update_roster(fantasy_id, desired_roster);
end;
$$;

commit;
