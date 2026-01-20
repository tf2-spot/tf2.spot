select p.steam_id as player_id
     , s.name as statistic
     , case
       when s.name = 'kills' then p.kills
       when s.name = 'deaths' then p.deaths
       when s.name = 'assists' then p.assists
       when s.name = 'suicides' then p.suicides
       when s.name = 'damage' then p.damage
       when s.name = 'damage_real' then p.damage_real
       when s.name = 'damage_taken' then p.damage_taken
       when s.name = 'damage_taken_real' then p.damage_taken_real
       when s.name = 'heals_received' then p.heals_received
       when s.name = 'longest_killstreak' then p.longest_killstreak
       when s.name = 'airshots' then p.airshots
       when s.name = 'medkits' then p.medkits
       when s.name = 'medkits_hp' then p.medkits_hp
       when s.name = 'backstabs' then p.backstabs
       when s.name = 'headshots' then p.headshots
       when s.name = 'headshots_hit' then p.headshots_hit
       when s.name = 'sentries' then p.sentries
       when s.name = 'point_captures' then p.point_captures
       when s.name = 'intel_captures' then p.intel_captures
       when s.name = 'charges' then p.charges
       when s.name = 'charges_uber' then p.charges_uber
       when s.name = 'charges_kritzkrieg' then p.charges_kritzkrieg
       when s.name = 'charges_vaccinator' then p.charges_vaccinator
       when s.name = 'charges_quickfix' then p.charges_quickfix
       when s.name = 'drops' then p.drops
       when s.name = 'advantages_lost' then p.advantages_lost
       when s.name = 'biggest_advantage_lost' then p.biggest_advantage_lost
       when s.name = 'deaths_with_95_uber' then p.deaths_with_95_uber
       when s.name = 'deaths_within_20s_after_uber' then p.deaths_within_20s_after_uber
       when s.name = 'average_time_before_healing' then p.average_time_before_healing
       when s.name = 'average_time_to_build' then p.average_time_to_build
       when s.name = 'average_time_before_using' then p.average_time_before_using
       when s.name = 'average_charge_length' then p.average_charge_length
       when s.name = 'kills_as_medic' then p.kills_as_medic
       else null
       end as value
from fantasy.logstf_document
, json_table(document, '$' columns
    ( nested '$.teams.keyvalue()[*]' columns
        ( team text path '$.key'
        -- , nested '$.value' columns
        --     ( .
        --     )
        )
    )
) as team
, json_table(document, '$.players.keyvalue()[*]' columns
    ( steam_id text path '$.key'
    , nested '$.value' columns
        ( team                         text  path '$.team'
        , kills                        int   path '$.kills'
        , deaths                       int   path '$.deaths'
        , assists                      int   path '$.assists'
        , suicides                     int   path '$.suicides'
        , damage                       int   path '$.dmg'
        , damage_real                  int   path '$.dmg_real'
        , damage_taken                 int   path '$.dt'
        , damage_taken_real            int   path '$.dt_real'
        , heals_received               int   path '$.hr'
        , longest_killstreak           int   path '$.lks'
        , airshots                     int   path '$.as'
        , medkits                      int   path '$.medkits'
        , medkits_hp                   int   path '$.medkits_hp'
        , backstabs                    int   path '$.backstabs'
        , headshots                    int   path '$.headshots'
        , headshots_hit                int   path '$.headshots_hit'
        , sentries                     int   path '$.sentries'
        , point_captures               int   path '$.cpc'
        , intel_captures               int   path '$.ic'
        , charges                      int   path '$.ubers'
        , charges_uber                 int   path '$.ubertypes.medigun'
        , charges_kritzkrieg           int   path '$.ubertypes.kritzkrieg'
        , charges_vaccinator           int   path '$.ubertypes.vaccinator'
        , charges_quickfix             int   path '$.ubertypes.quickfix'
        , drops                        int   path '$.drops'
        , advantages_lost              int   path '$.medicstats.advantages_lost'
        , biggest_advantage_lost       int   path '$.medicstats.biggest_advantage_lost'
        , deaths_with_95_uber          int   path '$.medicstats.deaths_with_95_99_uber'
        , deaths_within_20s_after_uber int   path '$.medicstats.deaths_within_20s_after_uber'
        , average_time_before_healing  float path '$.medicstats.avg_time_before_healing'
        , average_time_to_build        float path '$.medicstats.avg_time_to_build'
        , average_time_before_using    float path '$.medicstats.avg_time_before_using'
        , average_charge_length        float path '$.medicstats.avg_uber_length'
        , kills_as_medic               int   path '$.class_stats[*] ? (@.type == "medic").kills'
        )
    )
) as p
join fantasy.statistic as s on true;
