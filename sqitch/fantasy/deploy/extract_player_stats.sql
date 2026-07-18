-- Deploy fantasy:extract_player_stats to pg

begin;

set search_path to fantasy;

create view extract_player_stats as
with extract_player as (
  select log_id, json_table.*
  from logstf_document, json_table(document, '$.players.keyvalue()[*]' columns
  ( steam_id text path '$.key'
  , kills                  int path '$.value.kills'
  , assists                int path '$.value.assists'
  , deaths                 int path '$.value.deaths'
  , suicides               int path '$.value.suicides'
  , damage                 int path '$.value.dmg'
  , damage_real            int path '$.value.dmg_real'
  , damage_taken           int path '$.value.dt'
  , damage_taken_real      int path '$.value.dt_real'
  , heals_received         int path '$.value.hr'
  , longest_killstreak     int path '$.value.lks'
  , airshots               int path '$.value.as'
  , medkits                int path '$.value.medkits'
  , health_from_medkits    int path '$.value.medkits_hp'
  , backstabs              int path '$.value.backstabs'
  , headshot_kills         int path '$.value.headshots'
  , headshots              int path '$.value.headshots_hit'
  , sentries               int path '$.value.sentries'
  , heals                  int path '$.value.heal'
  , point_captures         int path '$.value.cpc'
  , intel_captures         int path '$.value.ic'
  , ubercharges            int path '$.value.ubers'
  , ubercharges_medigun    int path '$.value.ubertypes.medigun'
  , ubercharges_kritzkrieg int path '$.value.ubertypes.kritzkrieg'
  , ubercharges_vaccinator int path '$.value.ubertypes.vaccinator'
  , ubercharges_quickfix   int path '$.value.ubertypes.quickfix'
  , drops                  int path '$.value.drops'

  , advantages_lost              int   path '$.value.medicstats.advantages_lost'
  , biggest_advantage_lost       int   path '$.value.medicstats.biggest_advantage_lost'
  , deaths_with_95_99_uber       int   path '$.value.medicstats.deaths_with_95_99_uber'
  , deaths_within_20s_after_uber int   path '$.value.medicstats.deaths_within_20s_after_uber'
  , average_time_before_healing  float path '$.value.medicstats.avg_time_before_healing'
  , average_time_to_build        float path '$.value.medicstats.avg_time_to_build'
  , average_time_before_using    float path '$.value.medicstats.avg_time_before_using'
  , average_charge_length        float path '$.value.medicstats.avg_uber_length'

  , kills_as_scout   int path '$.value.class_stats[*] ? (@.type == "scout").kills'
  , assists_as_scout int path '$.value.class_stats[*] ? (@.type == "scout").assists'
  , deaths_as_scout  int path '$.value.class_stats[*] ? (@.type == "scout").deaths'
  , damage_as_scout  int path '$.value.class_stats[*] ? (@.type == "scout").dmg'
  , time_as_scout    int path '$.value.class_stats[*] ? (@.type == "scout").total_time'

  , kills_as_soldier   int path '$.value.class_stats[*] ? (@.type == "soldier").kills'
  , assists_as_soldier int path '$.value.class_stats[*] ? (@.type == "soldier").assists'
  , deaths_as_soldier  int path '$.value.class_stats[*] ? (@.type == "soldier").deaths'
  , damage_as_soldier  int path '$.value.class_stats[*] ? (@.type == "soldier").dmg'
  , time_as_soldier    int path '$.value.class_stats[*] ? (@.type == "soldier").total_time'

  , kills_as_pyro   int path '$.value.class_stats[*] ? (@.type == "pyro").kills'
  , assists_as_pyro int path '$.value.class_stats[*] ? (@.type == "pyro").assists'
  , deaths_as_pyro  int path '$.value.class_stats[*] ? (@.type == "pyro").deaths'
  , damage_as_pyro  int path '$.value.class_stats[*] ? (@.type == "pyro").dmg'
  , time_as_pyro    int path '$.value.class_stats[*] ? (@.type == "pyro").total_time'

  , kills_as_demoman   int path '$.value.class_stats[*] ? (@.type == "demoman").kills'
  , assists_as_demoman int path '$.value.class_stats[*] ? (@.type == "demoman").assists'
  , deaths_as_demoman  int path '$.value.class_stats[*] ? (@.type == "demoman").deaths'
  , damage_as_demoman  int path '$.value.class_stats[*] ? (@.type == "demoman").dmg'
  , time_as_demoman    int path '$.value.class_stats[*] ? (@.type == "demoman").total_time'

  , kills_as_heavyweapons   int path '$.value.class_stats[*] ? (@.type == "heavyweapons").kills'
  , assists_as_heavyweapons int path '$.value.class_stats[*] ? (@.type == "heavyweapons").assists'
  , deaths_as_heavyweapons  int path '$.value.class_stats[*] ? (@.type == "heavyweapons").deaths'
  , damage_as_heavyweapons  int path '$.value.class_stats[*] ? (@.type == "heavyweapons").dmg'
  , time_as_heavyweapons    int path '$.value.class_stats[*] ? (@.type == "heavyweapons").total_time'

  , kills_as_engineer   int path '$.value.class_stats[*] ? (@.type == "engineer").kills'
  , assists_as_engineer int path '$.value.class_stats[*] ? (@.type == "engineer").assists'
  , deaths_as_engineer  int path '$.value.class_stats[*] ? (@.type == "engineer").deaths'
  , damage_as_engineer  int path '$.value.class_stats[*] ? (@.type == "engineer").dmg'
  , time_as_engineer    int path '$.value.class_stats[*] ? (@.type == "engineer").total_time'

  , kills_as_medic   int path '$.value.class_stats[*] ? (@.type == "medic").kills'
  , assists_as_medic int path '$.value.class_stats[*] ? (@.type == "medic").assists'
  , deaths_as_medic  int path '$.value.class_stats[*] ? (@.type == "medic").deaths'
  , damage_as_medic  int path '$.value.class_stats[*] ? (@.type == "medic").dmg'
  , time_as_medic    int path '$.value.class_stats[*] ? (@.type == "medic").total_time'

  , kills_as_sniper   int path '$.value.class_stats[*] ? (@.type == "sniper").kills'
  , assists_as_sniper int path '$.value.class_stats[*] ? (@.type == "sniper").assists'
  , deaths_as_sniper  int path '$.value.class_stats[*] ? (@.type == "sniper").deaths'
  , damage_as_sniper  int path '$.value.class_stats[*] ? (@.type == "sniper").dmg'
  , time_as_sniper    int path '$.value.class_stats[*] ? (@.type == "sniper").total_time'

  , kills_as_spy   int path '$.value.class_stats[*] ? (@.type == "spy").kills'
  , assists_as_spy int path '$.value.class_stats[*] ? (@.type == "spy").assists'
  , deaths_as_spy  int path '$.value.class_stats[*] ? (@.type == "spy").deaths'
  , damage_as_spy  int path '$.value.class_stats[*] ? (@.type == "spy").dmg'
  , time_as_spy    int path '$.value.class_stats[*] ? (@.type == "spy").total_time'
  ))
)

, extract_class_kills as (
  select log_id, json_table.*
  from logstf_document, json_table(document, '$.classkills.keyvalue()[*]' columns
  ( steam_id text path '$.key'
  , kills_on_scout        int  path '$.value.scout'
  , kills_on_soldier      int  path '$.value.soldier'
  , kills_on_pyro         int  path '$.value.pyro'
  , kills_on_demoman      int  path '$.value.demoman'
  , kills_on_heavyweapons int  path '$.value.heavyweapons'
  , kills_on_engineer     int  path '$.value.engineer'
  , kills_on_medic        int  path '$.value.medic'
  , kills_on_sniper       int  path '$.value.sniper'
  , kills_on_spy          int  path '$.value.spy'
  ))
)

, extract_class_kill_participations as (
  select log_id, json_table.*
  from logstf_document, json_table (document , '$.classkillassists.keyvalue()[*]' columns
  ( steam_id text path '$.key'
  , kill_participations_on_scout        int  path '$.value.scout'
  , kill_participations_on_soldier      int  path '$.value.soldier'
  , kill_participations_on_pyro         int  path '$.value.pyro'
  , kill_participations_on_demoman      int  path '$.value.demoman'
  , kill_participations_on_heavyweapons int  path '$.value.heavyweapons'
  , kill_participations_on_engineer     int  path '$.value.engineer'
  , kill_participations_on_medic        int  path '$.value.medic'
  , kill_participations_on_sniper       int  path '$.value.sniper'
  , kill_participations_on_spy          int  path '$.value.spy'
  ))
)

, extract_class_deaths as (
  select log_id, json_table.*
  from logstf_document, json_table (document , '$.classdeaths.keyvalue()[*]' columns
  ( steam_id               text path '$.key'
  , deaths_to_scout        int  path '$.value.scout'
  , deaths_to_soldier      int  path '$.value.soldier'
  , deaths_to_pyro         int  path '$.value.pyro'
  , deaths_to_demoman      int  path '$.value.demoman'
  , deaths_to_heavyweapons int  path '$.value.heavyweapons'
  , deaths_to_engineer     int  path '$.value.engineer'
  , deaths_to_medic        int  path '$.value.medic'
  , deaths_to_sniper       int  path '$.value.sniper'
  , deaths_to_spy          int  path '$.value.spy'
  ))
)

select log_id
     , to_steamid64(steam_id)::text as steam_id
     , key as statistic
     , case when value = jsonb 'null' then 0 else value::decimal end as value
from (
  -- TODO: These UNIONs are problematic for postgREST
  select log_id, steam_id, key, value from extract_player, jsonb_each(to_jsonb(extract_player))
  union
  select log_id, steam_id, key, value from extract_class_kills, jsonb_each(to_jsonb(extract_class_kills))
  union
  select log_id, steam_id, key, value from extract_class_kill_participations, jsonb_each(to_jsonb(extract_class_kill_participations))
  union
  select log_id, steam_id, key, value from extract_class_deaths, jsonb_each(to_jsonb(extract_class_deaths))
)
where key not in ('log_id', 'steam_id');

comment on view extract_player_stats is 'internal';

commit;
