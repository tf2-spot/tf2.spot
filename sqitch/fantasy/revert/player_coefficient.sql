-- Revert fantasy:player_coefficient from pg

begin;

set search_path to fantasy, public;

drop table player_coefficient;

commit;
