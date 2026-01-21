with player as (
  select log_id, p.*, ck.*, cka.*, cd.*
  from fantasy.logstf_document
     , json_table
       ( document
       , '$.players.keyvalue()[*]' columns
         ( steam_id               text path '$.key'
         , team                   text path '$.value.team'
         , kills                  int  path '$.value.kills'
         , deaths                 int  path '$.value.deaths'
         , assists                int  path '$.value.assists'
         , suicides               int  path '$.value.suicides'
         , damage                 int  path '$.value.dmg'
         , damage_real            int  path '$.value.dmg_real'
         , damage_taken           int  path '$.value.dt'
         , damage_taken_real      int  path '$.value.dt_real'
         , heals_received         int  path '$.value.hr'
         , longest_killstreak     int  path '$.value.lks'
         , airshots               int  path '$.value.as'
         , medkits                int  path '$.value.medkits'
         , health_from_medkits    int  path '$.value.medkits_hp'
         , backstabs              int  path '$.value.backstabs'
         , headshot_kills         int  path '$.value.headshots'
         , headshots              int  path '$.value.headshots_hit'
         , sentries               int  path '$.value.sentries'
         , point_captures         int  path '$.value.cpc'
         , intel_captures         int  path '$.value.ic'
         , ubercharges            int  path '$.value.ubers'
         , ubercharges_medigun    int  path '$.value.ubertypes.medigun'
         , ubercharges_kritzkrieg int  path '$.value.ubertypes.kritzkrieg'
         , ubercharges_vaccinator int  path '$.value.ubertypes.vaccinator'
         , ubercharges_quickfix   int  path '$.value.ubertypes.quickfix'
         , drops                  int  path '$.value.drops'

         , advantages_lost              int   path '$.value.medicstats.advantages_lost'
         , biggest_advantage_lost       int   path '$.value.medicstats.biggest_advantage_lost'
         , deaths_with_95_uber          int   path '$.value.medicstats.deaths_with_95_99_uber'
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
         )
       ) as p

  left join json_table
    ( document
    , '$.classkills.keyvalue()[*]' columns
      ( steam_id              text path '$.key'
      , kills_on_scout        int  path '$.value.scout'
      , kills_on_soldier      int  path '$.value.soldier'
      , kills_on_pyro         int  path '$.value.pyro'
      , kills_on_demoman      int  path '$.value.demoman'
      , kills_on_heavyweapons int  path '$.value.heavyweapons'
      , kills_on_engineer     int  path '$.value.engineer'
      , kills_on_medic        int  path '$.value.medic'
      , kills_on_sniper       int  path '$.value.sniper'
      , kills_on_spy          int  path '$.value.spy'
      )
    )
    as ck on ck.steam_id = p.steam_id 

  left join json_table
    ( document
    , '$.classkillassists.keyvalue()[*]' columns
      ( steam_id                           text path '$.key'
      , kills_plus_assists_on_scout        int  path '$.value.scout'
      , kills_plus_assists_on_soldier      int  path '$.value.soldier'
      , kills_plus_assists_on_pyro         int  path '$.value.pyro'
      , kills_plus_assists_on_demoman      int  path '$.value.demoman'
      , kills_plus_assists_on_heavyweapons int  path '$.value.heavyweapons'
      , kills_plus_assists_on_engineer     int  path '$.value.engineer'
      , kills_plus_assists_on_medic        int  path '$.value.medic'
      , kills_plus_assists_on_sniper       int  path '$.value.sniper'
      , kills_plus_assists_on_spy          int  path '$.value.spy'
      )
    )
    as cka on cka.steam_id = p.steam_id 

  left join json_table
    ( document
    , '$.classdeaths.keyvalue()[*]' columns
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
      )
    )
    as cd on cd.steam_id = p.steam_id 
)

, team as (
  select log_id , t.*
  from fantasy.logstf_document
     , json_table
       ( document
       , '$.teams.keyvalue()[*]' columns
         ( team        text path '$.key'
         , kills       int  path '$.value.kills'
         , deaths      int  path '$.value.deaths'
         , damage      int  path '$.value.dmg'
         , ubercharges int  path '$.value.charges'
         , drops       int  path '$.value.drops'
         , first_caps  int  path '$.value.firstcaps'
         , caps        int  path '$.value.caps'
         )
       ) as t
)

select * from team;
