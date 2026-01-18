-- Deploy fantasy:log to pg

begin;

set search_path to fantasy, public;

create table log
( log_id   int not null
, fetched  timestamp
, document jsonb
, primary key (log_id)
);

comment on table log is '! JSON document from logs.tf, fetched automatically';

commit;
