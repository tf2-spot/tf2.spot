-- Revert fantasy:map from pg

begin;

set search_path to fantasy, public;

drop table map;

commit;
