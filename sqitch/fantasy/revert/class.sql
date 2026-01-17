-- Revert fantasy:class from pg

begin;

set search_path to fantasy, public;

drop table class;

commit;
