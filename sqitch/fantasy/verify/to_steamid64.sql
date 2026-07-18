-- Verify fantasy:to_steamid64 to pg

set search_path to fantasy;

do $$
begin
    assert to_steamid64('[U:1:59977210]') = 76561198020242938;
    assert to_steamid64('STEAM_0:0:29988605') = 76561198020242938;
end
$$;
