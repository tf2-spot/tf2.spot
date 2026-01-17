-- Revert fantasy:round from pg

begin;

set search_path to fantasy, public;

drop table round;

commit;
