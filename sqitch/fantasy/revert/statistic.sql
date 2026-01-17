-- Revert fantasy:statistic from pg

begin;

set search_path to fantasy, public;

drop table statistic;

commit;
