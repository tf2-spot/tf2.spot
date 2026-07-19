{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot;

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
      };
    };
  };

  config = mkIf cfg.fantasy.enable {
    security.acme.certs = mkIf cfg.tls {
      "${cfg.fantasy.domain}".group = "caddy";
    };

    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        "http${if cfg.tls then "s" else ""}://${cfg.fantasy.domain}" = {
          useACMEHost = mkIf cfg.tls "${cfg.fantasy.domain}";
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

      serviceConfig = {
        ExecStart = "${cfg.fantasy.package}/bin/gunicorn fantasy_website:app --config ${gunicornConfig}";
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";

        Type = "notify";
        NotifyAccess = "main";
        TimeoutStopSec = "5s";
        KillMode = "mixed";

        DynamicUser = true;
      };
    };
  };
}
