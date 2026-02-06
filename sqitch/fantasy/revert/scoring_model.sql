-- Revert fantasy:scoring_model from pg

begin;

set search_path to fantasy;

drop table scoring_model;

commit;
