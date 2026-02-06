-- Revert fantasy:logstf_document to pg

begin;

set search_path to fantasy;

drop table logstf_document;

commit;
