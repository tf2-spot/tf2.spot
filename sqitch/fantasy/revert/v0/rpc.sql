-- Revert fantasy:v0/rpc to pg

begin;

set search_path to fantasy_v0;

drop function update_roster(fantasy_id int, desired_roster int[]);

commit;
