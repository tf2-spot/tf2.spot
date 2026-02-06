-- Revert fantasy:participant from pg

begin;

set search_path to fantasy;

drop table participant;

commit;
