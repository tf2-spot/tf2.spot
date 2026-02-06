-- Revert fantasy:player_coefficient from pg

begin;

set search_path to fantasy;

drop table player_coefficient;

commit;
