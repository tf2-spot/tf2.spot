-- Revert fantasy:to_steamid64 to pg

begin;

set search_path to fantasy;

drop function to_steamid64(text);

commit;
