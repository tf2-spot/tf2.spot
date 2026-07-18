-- Revert fantasy:friendship from pg

begin;

set search_path to fantasy;

drop table friendship;

commit;
