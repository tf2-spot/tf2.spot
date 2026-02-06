-- Revert fantasy:manager from pg

begin;

set search_path to fantasy;

drop trigger ensure_last_login on manager;

drop function ensure_last_login;

drop table manager;

commit;
