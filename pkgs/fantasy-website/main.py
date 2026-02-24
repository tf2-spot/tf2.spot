import urllib.parse
from datetime import datetime, timedelta

import flask_assets
import httpx
import jwt
import postgrest
from babel.dates import format_datetime, format_timedelta
from flask import Flask, make_response, redirect, render_template, request, url_for
from whenever import Instant, OffsetDateTime

app = Flask(__name__)
app.config.from_prefixed_env()
app.jinja_options["autoescape"] = True
app.jinja_env.add_extension("jinja2.ext.debug")

assets = flask_assets.Environment(app)

STEAM_OPENID = "https://steamcommunity.com/openid/login"

COOKIE_AUTHN = "authn"
POSTGREST = "http://localhost:8080/postgrest"
JWT_SECRET = "m93oLRACWZOFGrgHiXFnp4mZoqL3qHy4"
JWT_ALGORITHM = "HS256"
JWT_ROLE = "fantasy_manager"


def api(auth=None):
    client = postgrest.SyncPostgrestClient(POSTGREST, schema="fantasy_v0")
    if auth is not None:
        client.auth(auth)
    return client


@app.route("/")
def homepage():
    client = api()
    tournaments = client.table("tournament").select().execute()
    return render_template("homepage.jinja", tournaments=tournaments.data)


@app.route("/me")
def my_profile():
    try:
        authn = jwt.decode(
            request.cookies[COOKIE_AUTHN], key=JWT_SECRET, algorithms=JWT_ALGORITHM
        )
        return redirect(url_for("manager", id=authn["manager_id"]))
    except KeyError:
        pass
    except jwt.DecodeError:
        pass
    return redirect(url_for("login"))


@app.route("/t/<slug>")
def tournament(slug):
    client = api()
    tournament = (
        client.table("tournament")
        .select(
            "*",
            """
            scoring_model(
                player_coefficient(
                    variable: player_statistic!variable(*),
                    divide_by: player_statistic!divide_by(*),
                    highest,
                    lowest,
                    coefficient
                ),
                team_coefficient(
                    variable: team_statistic(*),
                    coefficient
                )
            )
            """,
            "composition(*)",
            "upcoming_rounds: round(*)",
            "past_rounds: round(*)",
        )
        .eq("slug", slug)
        .gte("upcoming_rounds.time", "now")
        .order(foreign_table="upcoming_rounds", column="time")
        .lt("past_rounds.time", "now")
        .order(foreign_table="past_rounds", column="time")
        .maybe_single()
        .execute()
    )
    return render_template("tournament.jinja", tournament=tournament.data)


@app.route("/t/<slug>/manage")
def manage(slug):
    return render_template("manage.jinja")


@app.route("/t/<slug>/player-stats")
def player_stats(slug):
    tournament = (
        api()
        .table("tournament")
        .select(
            """
            id,
            slug,
            name,
            scoring_model(
                player_coefficient(
                    id,
                    variable: player_statistic!variable(*),
                    divide_by: player_statistic!divide_by(*),
                    highest,
                    lowest,
                    coefficient
                ),
                team_coefficient(
                    variable: team_statistic(*),
                    coefficient
                )
            ),
            team(
                *,
                participant(
                    *,
                    player(*),
                    total_score: player_performance(score),
                    perf: player_performance(
                        *,
                        player_coefficient(id)
                    )
                )
            )
            """
        )
        .eq("slug", slug)
        .is_("team.participant.total_score.round", "null")
        .is_("team.participant.total_score.match", "null")
        .is_("team.participant.total_score.map", "null")
        .is_("team.participant.total_score.player_coefficient", "null")
        .is_("team.participant.perf.round", "null")
        .is_("team.participant.perf.match", "null")
        .is_("team.participant.perf.map", "null")
        .not_.is_("team.participant.perf.player_coefficient", "null")
        .maybe_single()
        .execute()
    )
    return render_template("player_stats.jinja", tournament=tournament.data)


@app.route("/t/<slug>/leaderboard")
def leaderboard(slug):
    return render_template("leaderboard.jinja")


@app.route("/m/<id>")
def manager(id):
    client = api()
    manager = (
        client.table("manager")
        .select("*", "fantasy(*, tournament(*), contract(*))")
        .maybe_single()
        .execute()
    )
    return render_template("manager.jinja", manager=manager.data)


@app.route("/login")
def login():
    params = urllib.parse.urlencode(
        {
            "openid.ns": "http://specs.openid.net/auth/2.0",
            "openid.mode": "checkid_setup",
            "openid.return_to": f"{request.host_url}{url_for('openid_steam')}",
            "openid.realm": request.host_url,
            "openid.identity": "http://specs.openid.net/auth/2.0/identifier_select",
            "openid.claimed_id": "http://specs.openid.net/auth/2.0/identifier_select",
        }
    )
    return redirect(f"{STEAM_OPENID}?{params}", code=303)


@app.route("/openid/steam")
def openid_steam():
    try:
        validation = {
            k: request.args[k]
            for k in {
                f"openid.{signed}"
                for signed in request.args["openid.signed"].split(",")
            }
            | {"openid.assoc_handle", "openid.signed", "openid.sig", "openid.ns"}
        }
    except KeyError:
        return render_template("login-fail.jinja"), 401

    validation["openid.mode"] = "check_authentication"

    req = httpx.post(STEAM_OPENID, data=validation)

    if "is_valid:true" not in req.text:
        return render_template("login-fail.jinja"), 401

    id = request.args["openid.identity"].split("/")[-1]

    authn = jwt.encode(
        dict(role=JWT_ROLE, manager_id=id),
        key=JWT_SECRET,
        algorithm=JWT_ALGORITHM,
    )

    client = api(authn)
    req = (
        client.table("me")
        .upsert(dict(steam_id=id, last_login=Instant.now().format_common_iso()))
        .execute()
    )

    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(COOKIE_AUTHN, authn, max_age=timedelta(days=31))

    return resp


@app.route("/logout")
def logout():
    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(COOKIE_AUTHN, "", expires=0)
    return resp


@app.context_processor
def ctx_login():
    try:
        authn = jwt.decode(
            request.cookies[COOKIE_AUTHN], key=JWT_SECRET, algorithms=JWT_ALGORITHM
        )
        return dict(me=authn)
    except KeyError:
        pass
    except jwt.DecodeError:
        pass
    return dict(me=None)


@app.context_processor
def ctx_now():
    return dict(now=datetime.now())


@app.template_filter()
def to_now(dt):
    dt = OffsetDateTime.parse_common_iso(dt)
    now = Instant.now()
    delta = dt - now
    return format_timedelta(
        delta.py_timedelta(), locale="en_US", add_direction=True, threshold=2.4
    )


@app.template_filter("datetime")
def _datetime(dt):
    dt = OffsetDateTime.parse_common_iso(dt).to_tz("UTC")
    return format_datetime(dt.py_datetime(), "long", locale="en_US")


CLASS_ORDER = dict(
    scout=1, soldier=2, pyro=3, demoman=4, heavy=5, engineer=6, medic=7, sniper=8, spy=9
)


@app.template_filter()
def sort_by_main_class(participants):
    return sorted(participants, key=lambda p: CLASS_ORDER[p["main_class"]])


if __name__ == "__main__":
    app.run()
