-- Revert fantasy:map from pg

begin;

set search_path to fantasy;

drop table map;

commit;
