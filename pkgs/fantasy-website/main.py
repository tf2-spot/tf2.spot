import urllib.parse
from datetime import datetime, timedelta

import flask_assets
import httpx
import jwt
import postgrest
from flask import Flask, make_response, redirect, render_template, request, url_for

app = Flask(__name__)
app.config.from_prefixed_env()

assets = flask_assets.Environment(app)

SESSION_COOKIE = "session"
POSTGREST = "http://localhost:8080/postgrest"
STEAM_OPENID = "https://steamcommunity.com/openid/login"
JWT_SECRET = "m93oLRACWZOFGrgHiXFnp4mZoqL3qHy4"
JWT_ALGORITHM = "HS256"

api = postgrest.SyncPostgrestClient(POSTGREST, schema="fantasy_v0")


def get_session_cookie():
    try:
        return jwt.decode(
            request.cookies[SESSION_COOKIE], key=JWT_SECRET, algorithms=JWT_ALGORITHM
        )
    except:
        pass
    return None


@app.route("/")
def homepage():
    return render_template("homepage.jinja", me=get_session_cookie())


@app.route("/profiles/<id>")
def profile(id):
    return "Nah", 404


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
            for k in ("openid.assoc_handle", "openid.signed", "openid.sig", "openid.ns")
        }
    except KeyError:
        return render_template("login-fail.jinja", me=None), 401

    for signed in request.args["openid.signed"].split(","):
        key = f"openid.{signed}"
        if key not in validation:
            validation[key] = request.args[key]

    validation["openid.mode"] = "check_authentication"

    req = httpx.post(STEAM_OPENID, data=validation)

    app.logger.error(req)
    if "is_valid:true" not in req.text:
        return render_template("login-fail.jinja", me=None), 401

    id = request.args["openid.identity"].split("/")[-1]

    session = jwt.encode(
        dict(role="fantasy_manager", manager_id=id),
        key=JWT_SECRET,
        algorithm=JWT_ALGORITHM,
    )

    api.auth(session)
    req = (
        api.table("me")
        .upsert(dict(steam_id=id, last_login=datetime.now().isoformat()))
        .execute()
    )

    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(SESSION_COOKIE, session, max_age=timedelta(days=30))

    return resp


@app.route("/logout")
def logout():
    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(SESSION_COOKIE, "", expires=0)
    return resp


if __name__ == "__main__":
    app.run()
