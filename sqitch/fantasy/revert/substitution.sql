-- Revert fantasy:substitution to pg

begin;

set search_path to fantasy;

drop table substitution;

commit;
