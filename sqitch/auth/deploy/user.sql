-- Deploy auth:user to pg

begin;

set search_path to auth;

create table user
( steam_id       text not null
, alt_of         text
, steam_name     text
, steam_avatar   text
, steam_fetched  timestamptz
, preferred_name text
, timezone       text
-- security
, session_age    interval default '1 month'
, locked_until   timestamptz
-- moderation
, warning_note   text
, verified_name  text
, assigned_name  text
, muted_until    timestamptz
, hidden_until   timestamptz
, banned_until   timestamptz
, primary key (steam_id)
, foreign key (alt_of) references user
);

comment on table user is 'Steam user

commit;
