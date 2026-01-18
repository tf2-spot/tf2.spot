-- Revert fantasy:update_roster to pg

begin;

set search_path to fantasy, public;

drop function update_roster(fantasy_id int, desired_roster int[]);

commit;
