from datetime import datetime, timedelta
from flask import *
from flask_assets import Bundle, Environment
import jwt
import postgrest
import requests
import urllib.parse

app = Flask(__name__)
app.config.from_prefixed_env()

assets = Environment(app)

SESSION_COOKIE = "session"
POSTGREST = "http://localhost:8080/postgrest"
STEAM_OPENID = "https://steamcommunity.com/openid/login"
JWT_SECRET = "m93oLRACWZOFGrgHiXFnp4mZoqL3qHy4"
JWT_ALGORITHM = "HS256"

api = postgrest.SyncPostgrestClient(POSTGREST, schema="fantasy_v0")

def get_session_cookie():
    try:
        jwt.decode(request.cookies[SESSION_COOKIE], key=JWT_SECRET, algorithm=JWT_ALGORITHM)
    except:
        pass
    return None

@app.route("/")
def homepage():
    return render_template("homepage.html")

@app.route("/login")
def login():
    params = urllib.parse.urlencode({
        "openid.ns":"http://specs.openid.net/auth/2.0",
        "openid.mode": "checkid_setup",
        "openid.return_to": f"{request.host_url}openid/steam",
        "openid.realm": request.host_url,
        "openid.identity": "http://specs.openid.net/auth/2.0/identifier_select",
        "openid.claimed_id": "http://specs.openid.net/auth/2.0/identifier_select",
    })
    return redirect(f"{STEAM_OPENID}?{params}", code=303)

@app.route("/openid/steam")
def openid_steam():
    validation = { k: request.args[k] for k in ("openid.assoc_handle", "openid.signed", "openid.sig", "openid.ns") }

    for signed in request.args["openid.signed"].split(","):
        key = f"openid.{signed}"
        if key not in validation:
            validation[key] = request.args[key]

    validation['openid.mode'] = 'check_authentication'

    req = requests.post(STEAM_OPENID, validation)
    req.connection.close()

    if 'is_valid:true' not in req.text:
        return render_template("login-fail.html"), 401

    id = request.args["openid.identity"].split("/")[-1]

    session = jwt.encode(dict(role="fantasy_manager", manager_id=id), key=JWT_SECRET, algorithm=JWT_ALGORITHM)
    
    api.auth(session)
    req = api.table("me").upsert(dict(steam_id=id, last_login=datetime.now().isoformat())).execute()

    resp = make_response(redirect(url_for("homepage")))
    resp.set_cookie(SESSION_COOKIE, session, max_age=timedelta(days=30))

    return resp
