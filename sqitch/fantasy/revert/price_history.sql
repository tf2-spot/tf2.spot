-- Revert fantasy:price_history to pg

begin;

set search_path to fantasy, public;

drop table price_history;

commit;
