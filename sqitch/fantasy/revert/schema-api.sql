-- Revert fantasy:schema-api from pg

begin;

drop schema fantasy_api;

commit;
