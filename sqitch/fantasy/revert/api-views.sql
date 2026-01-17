-- Revert fantasy:api-views to pg

begin;

set search_path to fantasy_api, public;

drop view tournament;

commit;
