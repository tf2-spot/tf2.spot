-- Revert fantasy:v0/tournament to pg

begin;

set search_path to fantasy_v0;

drop view tournament;

commit;
