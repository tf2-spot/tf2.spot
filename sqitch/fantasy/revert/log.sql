-- Revert fantasy:logstf_document from pg

begin;

set search_path to fantasy, public;

drop table logstf_document;

commit;
