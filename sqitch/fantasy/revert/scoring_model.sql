-- Revert fantasy:scoring_model from pg

begin;

set search_path to fantasy, public;

drop table scoring_model;

commit;
