-- Revert fantasy:extract_player_stats to pg

begin;

set search_path to fantasy;

drop view extract_player_stats;

commit;
