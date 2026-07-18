-- Revert fantasy:role-visitor from pg

begin;

drop role fantasy_visitor;

commit;
