-- Revert fantasy:team_coefficient to pg

begin;

set search_path to fantasy, public;

drop table team_coefficient;

commit;
