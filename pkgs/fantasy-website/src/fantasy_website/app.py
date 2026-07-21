import urllib.parse

import flask_assets
import httpx
import jwt
import postgrest
from flask import (
    Flask,
    abort,
    flash,
    make_response,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from flask_babel import Babel
from werkzeug.middleware.proxy_fix import ProxyFix
from whenever import Instant, OffsetDateTime

STEAM_OPENID = "https://steamcommunity.com/openid/login"
COOKIE_AUTHN = "authn"
JWT_ALGORITHM = "HS256"
JWT_ROLE = "fantasy_manager"
CLASS_ORDER = [
    "scout",
    "soldier",
    "pyro",
    "demoman",
    "heavy",
    "engineer",
    "medic",
    "sniper",
    "spy",
]


app = Flask(__name__)

app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

app.config.from_prefixed_env()

app.jinja_options["autoescape"] = True
app.jinja_env.add_extension("jinja2.ext.debug")

assets = flask_assets.Environment(app)

babel = Babel(app)


def api(auth=None):
    client = postgrest.SyncPostgrestClient(app.config["POSTGREST"], schema="fantasy_v0")
    if auth is not None:
        client.auth(auth)
    return client


class NotAuthenticated(Exception):
    pass


def authn():
    try:
        return jwt.decode(
            request.cookies[COOKIE_AUTHN],
            key=app.config["JWT_SECRET"],
            algorithms=JWT_ALGORITHM,
        )
    except KeyError:
        raise NotAuthenticated from None
    except jwt.DecodeError:
        raise NotAuthenticated from None
    except jwt.ExpiredSignatureError:
        raise NotAuthenticated from None


@app.route("/")
def homepage():
    tournaments = (
        api().table("tournament").select("name, slug, start_time, end_time").execute()
    )
    resp = make_response(
        render_template("homepage.jinja", tournaments=tournaments.data)
    )
    resp.cache_control.public = True
    resp.cache_control.max_age = 600
    return resp


@app.route("/profiles/me")
def my_profile():
    try:
        return redirect(url_for("manager", id=authn()["manager_id"]))
    except NotAuthenticated:
        return redirect(url_for("login", next=request.path))


@app.route("/t/<slug>")
def tournament(slug):
    tournament = (
        api()
        .table("tournament")
        .select("""
            *,
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
            ),
            composition(*),
            upcoming_rounds: round(name, time),
            past_rounds: round(name, time)
        """)
        .eq("slug", slug)
        .order(
            foreign_table="scoring_model.player_coefficient",
            column="highest,lowest,variable,divide_by",
        )
        .order(foreign_table="scoring_model.team_coefficient", column="variable")
        .gte("upcoming_rounds.time", "now")
        .order(foreign_table="upcoming_rounds", column="time")
        .lt("past_rounds.time", "now")
        .order(foreign_table="past_rounds", column="time")
        .maybe_single()
        .execute()
    )

    if tournament is None:
        abort(404)

    resp = make_response(
        render_template("tournament.jinja", tournament=tournament.data)
    )
    resp.cache_control.public = True
    resp.cache_control.max_age = 600
    return resp


@app.route("/t/<slug>/manage", methods=["GET", "POST"])
def manage(slug):
    if "add" in request.form:
        session[slug] = list(set(session.get(slug) or []) | {int(request.form["add"])})
        return redirect(request.path)

    if "remove" in request.form:
        session[slug] = list(
            set(session.get(slug) or []) - {int(request.form["remove"])}
        )
        return redirect(request.path)

    try:
        auth = authn()
    except NotAuthenticated:
        return redirect(url_for("login", next=request.path))

    if "name" in request.form:
        client = api(request.cookies[COOKIE_AUTHN])

        tournament = (
            client.table("tournament")
            .select("id", "initial_budget")
            .eq("slug", slug)
            .single()
            .execute()
        )

        (
            client.table("my_fantasy")
            .upsert(
                dict(
                    tournament=tournament.data["id"],
                    manager=auth["manager_id"],
                    name=request.form["name"].strip() or "Unnamed team",
                    initial_budget=tournament.data["initial_budget"],
                ),
                on_conflict="tournament,manager",
            )
            .execute()
        )
        return redirect(request.path)

    if "reset" in request.form:
        x = (
            api(request.cookies[COOKIE_AUTHN])
            .table("tournament")
            .select("...my_fantasy(...contract(...participant(id)))")
            .eq("slug", slug)
            .is_("my_fantasy.contract.time_terminated", "null")
            .single()
            .execute()
        )

        session[slug] = x.data["id"]
        return redirect(request.path)

    if "commit" in request.form:
        if session.get(slug) is None:
            flash("You need players in your roster", "error")
            return redirect(request.path)

        client = api(request.cookies[COOKIE_AUTHN])

        tournament = (
            client.table("tournament")
            .select("id", "initial_budget")
            .eq("slug", slug)
            .single()
            .execute()
        )

        my_fantasy = (
            client.table("my_fantasy")
            .upsert(
                dict(
                    tournament=tournament.data["id"],
                    manager=auth["manager_id"],
                    initial_budget=tournament.data["initial_budget"],
                ),
                on_conflict="tournament,manager",
                returning="representation",
            )
            .execute()
        )

        try:
            client.rpc(
                "update_roster",
                dict(
                    fantasy_id=my_fantasy.data[0]["id"],
                    desired_roster=session[slug],
                ),
            ).execute()
        except postgrest.APIError as e:
            flash(e.message or "Not really sure but something went wrong", "error")

        return redirect(request.path)

    tournament = (
        api(request.cookies[COOKIE_AUTHN])
        .table("tournament")
        .select("""
            my_fantasy(
                *,
                active: contract(
                    id,
                    participant(id),
                    contract_value(
                        score,
                        round(name, time)
                    )
                ),
                old: contract(
                    id,
                    participant(id),
                    contract_value(
                        score,
                        round(name, time)
                    )
                )
            ),
            participant(
                id,
                ...player(name),
                main_class,
                price,
                team(name, tag)
            )
        """)
        .eq("slug", slug)
        .order(foreign_table="my_fantasy.active", column="time_signed")
        .is_("my_fantasy.active.time_terminated", "null")
        .order(foreign_table="my_fantasy.active.contract_value", column="round(time)")
        .not_.is_("my_fantasy.active.contract_value.score", "null")
        .order(foreign_table="my_fantasy.old", column="time_signed")
        .not_.is_("my_fantasy.old.time_terminated", "null")
        .order(foreign_table="my_fantasy.old.contract_value", column="round(time)")
        .not_.is_("my_fantasy.old.contract_value.score", "null")
        .order(
            foreign_table="participant",
            column="team",
        )
        .maybe_single()
        .execute()
    )

    if tournament is None:
        abort(404)

    return render_template("manage.jinja", tournament=tournament.data)


@app.route("/t/<slug>/player-stats")
def player_stats(slug):
    if request.args.get("round") == "":
        return redirect(request.path)

    req = (
        api()
        .table("tournament")
        .select("""
            id,
            slug,
            name,
            round(id, name),
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
        """)
        .eq("slug", slug)
        .order(foreign_table="round", column="time")
        .order(
            foreign_table="scoring_model.player_coefficient",
            column="highest,lowest,variable,divide_by",
        )
        .order(foreign_table="scoring_model.team_coefficient", column="variable")
        .is_("team.participant.total_score.match", "null")
        .is_("team.participant.total_score.map", "null")
        .is_("team.participant.total_score.player_coefficient", "null")
        .is_("team.participant.perf.match", "null")
        .is_("team.participant.perf.map", "null")
        .not_.is_("team.participant.perf.player_coefficient", "null")
    )

    if request.args.get("round"):
        req = (
            (req)
            .eq("team.participant.total_score.round", request.args["round"])
            .eq("team.participant.perf.round", request.args["round"])
        )
    else:
        req = (
            (req)
            .is_("team.participant.total_score.round", "null")
            .is_("team.participant.perf.round", "null")
        )

    tournament = req.maybe_single().execute()

    if tournament is None:
        abort(404)

    resp = make_response(
        render_template("player_stats.jinja", tournament=tournament.data)
    )
    resp.cache_control.public = True
    resp.cache_control.max_age = 600
    return resp


@app.route("/t/<slug>/leaderboard")
def leaderboard(slug):
    tournament = (
        api()
        .table("tournament")
        .select("""
            name,
            fantasy(
                *,
                manager(steam_id, name),
                ...fantasy_value(score, rank)
            )
        """)
        .eq("slug", slug)
        .not_.is_("fantasy.fantasy_value", "null")
        .order(foreign_table="fantasy", column="fantasy_value(rank)")
        .maybe_single()
        .execute()
    )

    if tournament is None:
        abort(404)

    resp = make_response(
        render_template("leaderboard.jinja", tournament=tournament.data)
    )
    resp.cache_control.public = True
    resp.cache_control.max_age = 600
    return resp


@app.route("/t/<slug>/<id>")
def fantasy(slug, id):
    fantasy = (
        api()
        .table("fantasy")
        .select("""
            *,
            tournament!inner(slug),
            manager(steam_id, name),
            ...fantasy_value(score, rank),
            active: contract(
                id,
                time_signed,
                participant(
                    main_class,
                    price,
                    ...player(name),
                    team(name, tag)
                ),
                contract_value(
                    score,
                    round(name, time)
                )
            ),
            old: contract(
                id,
                time_signed,
                time_terminated,
                participant(
                    main_class,
                    price,
                    ...player(name),
                    team(name, tag)
                ),
                contract_value(
                    score,
                    round(name, time)
                )
            )
        """)
        .eq("tournament.slug", slug)
        .eq("manager", id)
        .order(foreign_table="active", column="time_signed")
        .is_("active.time_terminated", "null")
        .order(foreign_table="active.contract_value", column="round(time)")
        .not_.is_("active.contract_value.score", "null")
        .order(foreign_table="old", column="time_signed")
        .not_.is_("old.time_terminated", "null")
        .order(foreign_table="old.contract_value", column="round(time)")
        .not_.is_("old.contract_value.score", "null")
        .maybe_single()
        .execute()
    )

    if fantasy is None:
        abort(404)

    resp = make_response(render_template("fantasy.jinja", fantasy=fantasy.data))
    resp.cache_control.public = True
    resp.cache_control.max_age = 600
    return resp


@app.route("/profiles/<id>")
def manager(id):
    manager = (
        api()
        .table("manager")
        .select("""
            name,
            avatar,
            steam_id,
            fantasy(
                name,
                ...fantasy_value(score, rank),
                contract(participant(player(name), main_class)),
                tournament(name, slug, start_time)
            )
        """)
        .eq("steam_id", id)
        .order(foreign_table="fantasy", column="tournament(start_time)")
        .is_("fantasy.contract.time_terminated", "null")
        .order(foreign_table="fantasy.contract", column="participant(main_class)")
        .maybe_single()
        .execute()
    )

    if manager is None:
        abort(404)

    try:
        is_me = manager.data["steam_id"] == authn()["manager_id"]
    except NotAuthenticated:
        is_me = False

    resp = make_response(
        render_template("manager.jinja", manager=manager.data, is_me=is_me)
    )
    resp.cache_control.public = True
    resp.cache_control.max_age = 600
    return resp


@app.route("/login")
def login():
    params = urllib.parse.urlencode(
        {
            "openid.ns": "http://specs.openid.net/auth/2.0",
            "openid.mode": "checkid_setup",
            "openid.return_to": f"{request.host_url}{url_for('openid_steam', next=request.args.get('next'))}",
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
        dict(
            role=JWT_ROLE,
            manager_id=id,
            exp=Instant.now().add(hours=14 * 24).to_stdlib(),
        ),
        key=app.config["JWT_SECRET"],
        algorithm=JWT_ALGORITHM,
    )

    req = (
        api(authn)
        .table("me")
        .upsert(dict(steam_id=id, last_login=Instant.now().format_iso()))
        .execute()
    )

    route = request.args.get("next", "!!!")

    if not app.url_map.bind(request.host).test(route):
        route = url_for("homepage")

    resp = make_response(redirect(route))
    resp.set_cookie(COOKIE_AUTHN, authn, max_age=31 * 24 * 60 * 60)
    resp.cache_control.no_store = True

    return resp


@app.route("/logout")
def logout():
    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(COOKIE_AUTHN, "", expires=0)
    resp.cache_control.no_store = True
    return resp


@app.context_processor
def ctx_login():
    try:
        authn = jwt.decode(
            request.cookies[COOKIE_AUTHN],
            key=app.config["JWT_SECRET"],
            algorithms=JWT_ALGORITHM,
        )
        return dict(me=authn)
    except KeyError:
        pass
    except jwt.DecodeError:
        pass
    except jwt.ExpiredSignatureError:
        pass
    return dict(me=None)


@app.template_filter()
def diffnow(dt):
    return (OffsetDateTime(dt) - Instant.now()).to_stdlib()


@app.template_filter()
def parsedatetime(dt):
    return OffsetDateTime.parse_iso(dt).to_stdlib()


@app.template_filter()
def sort_by_main_class(participants):
    return sorted(participants, key=lambda p: CLASS_ORDER.index(p["main_class"]))


@app.template_filter()
def to_map(participants):
    return {x["id"]: x for x in participants}


@app.errorhandler(404)
def handle_not_found(_):
    return render_template("not-found.jinja")


def main():
    app.run()


if __name__ == "__main__":
    main()

__all__ = ["app", "main"]
