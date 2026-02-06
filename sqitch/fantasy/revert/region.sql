-- Revert fantasy:region from pg

begin;

set search_path to fantasy;

drop table region;

commit;
