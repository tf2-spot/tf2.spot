-- Revert fantasy:round from pg

begin;

set search_path to fantasy;

drop table round;

commit;
