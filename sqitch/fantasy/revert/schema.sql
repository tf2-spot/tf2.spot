-- Revert fantasy:schema from pg

begin;

drop schema fantasy;

commit;
