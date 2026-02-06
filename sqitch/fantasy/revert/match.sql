-- Revert fantasy:match from pg

begin;

set search_path to fantasy;

drop table match;

commit;
