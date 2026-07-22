-- Revert fantasy:role-janitor to pg

begin;

drop role fantasy_janitor;

commit;
