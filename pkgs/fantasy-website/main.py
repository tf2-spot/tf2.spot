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
app.jinja_env.add_extension("jinja2.ext.debug")

assets = flask_assets.Environment(app)

AUTHN_COOKIE = "authn"
POSTGREST = "http://localhost:8080/postgrest"
STEAM_OPENID = "https://steamcommunity.com/openid/login"
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
        .lt("past_rounds.time", "now")
        .maybe_single()
        .execute()
    )
    return render_template("tournament.jinja", tournament=tournament.data)


@app.route("/t/<slug>/manage")
def manage(slug):
    return render_template("manage.jinja")


@app.route("/t/<slug>/participants")
def participants(slug):
    return render_template("participants.jinja")


@app.route("/m/<id>")
def manager(id):
    return render_template("manager.jinja")


@app.route("/login")
def login():
    params = urllib.parse.urlencode(
        {
            "openid.ns": "http://specs.openid.net/auth/2.0",
            "openid.mode": "checkid_setup",
            "openid.return_to": f"{request.host_url}openid/steam",
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
        .upsert(dict(steam_id=id, last_login=datetime.now().isoformat()))
        .execute()
    )

    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(AUTHN_COOKIE, authn, max_age=timedelta(days=31))

    return resp


@app.route("/logout")
def logout():
    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(AUTHN_COOKIE, "", expires=0)
    return resp


@app.context_processor
def ctx_login():
    try:
        authn = jwt.decode(
            request.cookies[AUTHN_COOKIE], key=JWT_SECRET, algorithms=JWT_ALGORITHM
        )
        return dict(me=authn)
    except KeyError:
        pass
    except jwt.DecodeError:
        pass
    return dict(me=None)


@app.template_filter()
def to_now(dt):
    dt = OffsetDateTime.parse_common_iso(dt)
    now = Instant.now()
    delta = dt - now
    delta = delta.py_timedelta()
    return format_timedelta(delta, locale="en_US", add_direction=True, threshold=2.4)


@app.template_filter("datetime")
def _datetime(dt):
    dt = OffsetDateTime.parse_common_iso(dt).to_tz("UTC")
    return format_datetime(dt.py_datetime(), "long", locale="en_US")


if __name__ == "__main__":
    app.run()
