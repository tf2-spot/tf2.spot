-- Revert fantasy:match from pg

begin;

set search_path to fantasy, public;

drop table match;

commit;
