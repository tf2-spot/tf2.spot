-- Revert auth:access_token to pg

begin;

set search_path to auth;



commit;
