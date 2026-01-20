-- Deploy fantasy:to_steamid64 to pg

begin;

set search_path to fantasy, public;

create function to_steamid64(text)
returns bigint
language plpgsql
immutable
strict
as $$
declare
    modern_format text = '\[U:(\d+):(\d+)\]';
    legacy_format text = 'STEAM_(\d+):(\d+):(\d+)';
    account_type bigint = 76561197960265728;
    parts text[];
begin
    if $1 similar to modern_format then
        parts := regexp_match($1, modern_format);
        return account_type + parts[2]::bigint;
    elsif $1 similar to legacy_format then
        parts := regexp_match($1, legacy_format);
        return account_type + parts[2]::bigint + parts[3]::bigint * 2;
    end if;

    raise exception 'Invalid Steam ID';
end;
$$;

commit;
