-- Revert fantasy:multiplier from pg

begin;

set search_path to fantasy, public;

drop table multiplier;

commit;
