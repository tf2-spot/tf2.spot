-- Revert fantasy:class from pg

begin;

set search_path to fantasy;

drop table class;

commit;
