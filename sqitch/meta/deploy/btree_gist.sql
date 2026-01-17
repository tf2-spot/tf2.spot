-- Deploy meta:btree_gist to pg

begin;

create extension btree_gist;

commit;
