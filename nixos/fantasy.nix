{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot.fantasy;

  gunicornConfig = pkgs.writeText "gunicorn.conf.py" ''
    import multiprocessing

    bind = ['[::1]:8180']
    proxy_protocol = 'v2'

    workers = multiprocessing.cpu_count() * 2 + 1
    preload_app = True
  '';
in
{
  options = {
    tf2-spot = {
      fantasy = {
        enable = mkEnableOption "";

        package = mkOption {
          type = types.raw;
        };

        domain = mkOption {
          type = types.str;
          default = "fantasy.tf2.spot";
        };

        tls = mkEnableOption "" // { default = true; };

        url = mkOption {
          type = types.str;
          internal = true;
          default = "http${lib.optionalString cfg.tls "s"}://${cfg.domain}";
        };

        envFile = mkOption {
          type = with types; nullOr str;
          default = null;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    security.acme.certs = mkIf cfg.tls {
      "${cfg.domain}".group = "caddy";
    };

    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        "${cfg.url}" = {
          useACMEHost = mkIf cfg.tls "${cfg.domain}";
          extraConfig = ''
            reverse_proxy {
              to http://localhost:8180
              transport http {
                proxy_protocol v2
              }
            }
          '';
        };
      };
    };

    systemd.services.fantasy-website = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        FLASK_POSTGREST = config.tf2-spot.postgrest.url;
        FLASK_ASSETS_CACHE = "%C/fantasy-website/webassets";
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/gunicorn fantasy_website:app --config ${gunicornConfig}";
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";

        EnvironmentFile = cfg.envFile;

        Type = "notify";
        NotifyAccess = "main";
        TimeoutStopSec = "5s";
        KillMode = "mixed";

        DynamicUser = true;
        CacheDirectory = "fantasy-website";
      };
    };
  };
}
