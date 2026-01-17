-- Revert fantasy:create_transaction to pg

begin;

set search_path to fantasy, public;

drop function create_transaction(team_id int, desired_roster int[]);

commit;
