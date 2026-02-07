-- Deploy fantasy:v0/me to pg

begin;

set search_path to fantasy_v0;

create view me as
select *
from fantasy.manager
where steam_id = current_setting('request.jwt.claims', true)::json->>'manager_id';

commit;
