-- Revert fantasy:price_history to pg

begin;

set search_path to fantasy;

drop trigger trigger_price_history on participant;

drop function trigger_price_history;

drop table price_history;

commit;
