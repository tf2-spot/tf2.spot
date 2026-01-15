-- Deploy meta:btree_gist to pg

BEGIN;

create extension btree_gist;

COMMIT;
