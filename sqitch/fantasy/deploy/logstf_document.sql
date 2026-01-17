-- Deploy fantasy:logstf_document to pg

begin;

set search_path to fantasy, public;

create table logstf_document
( log_id   int not null
, document jsonb
, fetched  timestamp
, primary key (log_id)
);

commit;
