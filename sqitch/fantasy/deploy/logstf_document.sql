-- Deploy fantasy:logstf_document to pg

begin;

set search_path to fantasy;

create table logstf_document
( log_id   int       not null
, fetched  timestamp not null
, document jsonb     not null
, primary key (log_id)
);

comment on table logstf_document is 'JSON document from logs.tf, fetched automatically';

commit;
