-- Deploy fantasy:manager to pg

begin;

set search_path to fantasy;

create table manager
( steam_id    text not null
, last_login  timestamptz not null
, fetched     timestamptz
, name        text
, avatar      mathesar_types.uri
, muted_until timestamptz
, primary key (steam_id)
);

comment on table manager is 'person taking part in the game of Fantasy TF2';

create function ensure_last_login()
returns trigger
language plpgsql
as $$
begin
    if new.last_login < now() - interval '1 minute' then
        new.last_login = now();
    end if;

    return new;
end;
$$;

create trigger ensure_last_login
after update of last_login on manager
for each row
execute function ensure_last_login();

commit;
