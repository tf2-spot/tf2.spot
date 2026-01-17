-- Revert fantasy:participant from pg

begin;

set search_path to fantasy, public;

drop table participant;

commit;
