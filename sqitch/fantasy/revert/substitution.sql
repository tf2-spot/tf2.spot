-- Revert fantasy:substitution to pg

begin;

set search_path to fantasy, public;

drop table substitution;

commit;
