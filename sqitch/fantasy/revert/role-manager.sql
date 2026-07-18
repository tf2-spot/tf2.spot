-- Revert fantasy:role-manager from pg

begin;

drop role fantasy_manager;

commit;
