-- Revert fantasy:real_team from pg

begin;

set search_path to fantasy, public;

drop table real_team;

commit;
