-- Deploy auth:access_token to pg

begin;

set search_path to auth;

create table access_token
( token        uuid not null default uuidv7()
, session      int not null
, created_at   timestamptz not null default now()
, created_from inet not null
, expires_at   timestamptz not null default now() + '10 minutes'
, primary key (access_token)
, foreign key (session) references session
);

commit;
