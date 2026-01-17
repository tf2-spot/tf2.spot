-- Revert fantasy:region from pg

begin;

set search_path to fantasy, public;

drop table region;

commit;
