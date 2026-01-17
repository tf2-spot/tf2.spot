-- Revert fantasy:performance to pg

begin;

set search_path to fantasy, public;

drop table performance;

commit;
