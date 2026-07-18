-- Deploy fantasy:player_statistic to pg

begin;

set search_path to fantasy;

create table player_statistic
( id          text not null
, short       text not null
, description text not null
, primary key (id)
);

comment on table player_statistic is 'static set of possible measurements of a player during a map';

copy player_statistic (id, short, description) from stdin with delimiter ',';
advantages_lost,Ad lost,übercharge advantage lost
airshots,Airshots,airshots
assists,Assists,assists
assists_as_demoman,,
assists_as_engineer,,
assists_as_heavyweapons,,
assists_as_medic,,
assists_as_pyro,,
assists_as_scout,,
assists_as_sniper,,
assists_as_soldier,,
assists_as_spy,,
average_charge_length,,
average_time_before_healing,,
average_time_before_using,,
average_time_to_build,,
backstabs,Backstabs,backstabs
biggest_advantage_lost,,
damage,Damage,damage dealt
damage_as_demoman,,
damage_as_engineer,,
damage_as_heavyweapons,,
damage_as_medic,,
damage_as_pyro,,
damage_as_scout,,
damage_as_sniper,,
damage_as_soldier,,
damage_as_spy,,
damage_real,,
damage_taken,Damage taken,damage taken
damage_taken_real,,
deaths,Deaths,deaths
deaths_as_demoman,,
deaths_as_engineer,,
deaths_as_heavyweapons,,
deaths_as_medic,,
deaths_as_pyro,,
deaths_as_scout,,
deaths_as_sniper,,
deaths_as_soldier,,
deaths_as_spy,,
deaths_to_demoman,,
deaths_to_engineer,,
deaths_to_heavyweapons,,
deaths_to_medic,,
deaths_to_pyro,,
deaths_to_scout,,
deaths_to_sniper,,
deaths_to_soldier,,
deaths_to_spy,,
deaths_with_95_99_uber,,
deaths_within_20s_after_uber,,
drops,Drops,dropped übercharges
headshot_kills,Headshot Kills,kills with a headshot
headshots,,
heals,Heals,heals
heals_received,,
health_from_medkits,Health picked up,heals gathered from health kits
intel_captures,,
kill_participations_on_demoman,,
kill_participations_on_engineer,,
kill_participations_on_heavyweapons,,
kill_participations_on_medic,,
kill_participations_on_pyro,,
kill_participations_on_scout,,
kill_participations_on_sniper,,
kill_participations_on_soldier,,
kill_participations_on_spy,,
kills,Kills,kills
kills_as_demoman,,
kills_as_engineer,,
kills_as_heavyweapons,,
kills_as_medic,Kills as Medic,kills as Medic
kills_as_pyro,,
kills_as_scout,,
kills_as_sniper,,
kills_as_soldier,,
kills_as_spy,,
kills_on_demoman,,
kills_on_engineer,,
kills_on_heavyweapons,,
kills_on_medic,Medic Kills,enemy Medics killed
kills_on_pyro,,
kills_on_scout,,
kills_on_sniper,,
kills_on_soldier,,
kills_on_spy,,
longest_killstreak,,
medkits,,
point_captures,Captures,points captured
sentries,,
suicides,,
time_as_demoman,,
time_as_engineer,,
time_as_heavyweapons,,
time_as_medic,,
time_as_pyro,,
time_as_scout,,
time_as_sniper,,
time_as_soldier,,
time_as_spy,,
ubercharges,Übers,übercharges used
ubercharges_kritzkrieg,,
ubercharges_medigun,,
ubercharges_quickfix,,
ubercharges_vaccinator,,
\.

commit;
