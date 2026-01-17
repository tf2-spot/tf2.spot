-- Revert fantasy:friendship from pg

begin;

set search_path to fantasy, public;

drop table friendship;

commit;
