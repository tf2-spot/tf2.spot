import logging
import os

import httpx
import psycopg
from psycopg.rows import scalar_row
from psycopg.types.json import Jsonb

log = logging.getLogger(__name__)

LOG_LEVEL = os.getenv("LOG_LEVEL", logging.INFO)
STEAM_API = os.getenv("STEAM_API", "https://api.steampowered.com")
STEAM_API_KEY = os.getenv("STEAM_API_KEY", "SentinelNotDefined")
LOGS_TF_API = os.getenv("LOGS_TF_API", "https://logs.tf/api/v1")


def fetch_missing_steam_users(conn):
    log.debug("Fetching missing Steam users")
    with conn.cursor(row_factory=scalar_row) as cursor:
        cursor.execute("""
            select steam_id from fantasy.manager
            where fetched is null
            or age(last_login, fetched) > '7 days'
            or age(fetched) > '30 days'
            limit 100
        """)

        steamids = cursor.fetchall()

        if steamids == []:
            log.debug("Found no users to update")
            return

        log.info("Found %d users to update", len(steamids))

        resp = httpx.get(
            f"{STEAM_API}/ISteamUser/GetPlayerSummaries/v2/",
            params={
                "key": STEAM_API_KEY,
                "steamids": ",".join(steamids),
            },
        )

        players = []
        for p in resp.json()["response"]["players"]:
            players.append((p["personaname"], p["avatarfull"], p["steamid"]))

        if players == []:
            log.warning("Steam API returned an empty set of users")
            return

        log.info("Updating %d users", len(players))
        cursor.executemany(
            """
                update fantasy.manager
                set name = %s, avatar = %s, fetched = now()
                where steam_id = %s
            """,
            players,
        )
        log.info("Updated %d", cursor.rowcount)


def fetch_missing_logs(conn):
    log.debug("Fetching missing logs.tf documents")

    client = httpx.Client()

    with conn.cursor() as cursor:
        cursor.execute("""
            select id, map.log_id, golden_cap_log_id
            from fantasy.map
            left join fantasy.logstf_document main on map.log_id = main.log_id
            left join fantasy.logstf_document gc on map.golden_cap_log_id = gc.log_id
            where (map.log_id is not null and main.log_id is null)
            or (map.golden_cap_log_id is not null and gc.log_id is null)
            limit 10
        """)

        documents = []

        for id, main_id, gc_id in cursor:
            if main_id is not None:
                log.info("Fetching https://logs.tf/%d for map %d", main_id, id)
                r = client.get(f"{LOGS_TF_API}/log/{main_id}")
                documents.append((main_id, Jsonb(r.json())))

            if gc_id is not None:
                log.info("Fetching https://logs.tf/%d for map %d golden cap", gc_id, id)
                r = client.get(f"{LOGS_TF_API}/log/{gc_id}")
                documents.append((gc_id, Jsonb(r.json())))

        if documents == []:
            log.debug("Found no logs to fetch")
            return

        log.info("Inserting %d logs.tf documents", len(documents))
        cursor.executemany(
            """
                insert into fantasy.logstf_document (log_id, document, fetched)
                values (%s, %s, now())
            """,
            documents,
        )
        log.info("Inserted %d", cursor.rowcount)

        log.warning("Refreshing materialized views!")
        cursor.execute("refresh materialized view fantasy.player_performance")
        cursor.execute("refresh materialized view fantasy.team_performance")


class HideSecretFormatter(logging.Formatter):
    def format(self, record):
        original: str = super().format(record)
        return original.replace(STEAM_API_KEY, "$STEAM_API_KEY")


def main() -> None:
    logging.basicConfig(level=LOG_LEVEL)
    for handler in logging.root.handlers:
        handler.setFormatter(
            HideSecretFormatter("%(name)s [%(levelname)s] %(message)s")
        )

    if STEAM_API_KEY == "SentinelNotDefined":
        log.error("You must define STEAM_API_KEY in the environment")
        exit(1)

    log.debug("Hello")
    with psycopg.connect() as conn:
        fetch_missing_steam_users(conn)
        fetch_missing_logs(conn)
    log.debug("Goodbye")
