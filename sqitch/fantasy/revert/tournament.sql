-- Revert fantasy:tournament from pg

BEGIN;

drop table fantasy.tournament;

COMMIT;
