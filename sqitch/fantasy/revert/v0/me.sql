-- Revert fantasy:v0/me to pg

begin;

set search_path to fantasy_v0;

drop view me;

commit;
