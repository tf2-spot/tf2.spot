{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot;
in
{
  options = {
    tf2-spot = {
      mathesar = {
        enable = mkEnableOption "";

        version = mkOption {
          type = types.str;
        };

        domain = mkOption {
          type = types.str;
          default = "mathesar.tf2.spot";
        };

        envFile = mkOption {
          type = with types; nullOr path;
          default = null;
        };
      };
    };
  };

  config = mkIf cfg.mathesar.enable {
    security.acme.certs = mkIf cfg.tls {
      "${cfg.mathesar.domain}".group = "caddy";
    };

    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        "http${if cfg.tls then "s" else ""}://${cfg.mathesar.domain}" = {
          useACMEHost = mkIf cfg.tls "${cfg.mathesar.domain}";
          extraConfig = ''
            reverse_proxy http://localhost:8280
          '';
        };
      };
    };

    systemd.services.podman-mathesar = {
      # Mathesar gets stuck with no socket when postgresql restarts,
      # make it stop when postgresql stops.
      after = [ "postgresql.service" ];
      bindsTo = [ "postgresql.service" ];
    };

    users = {
      users.mathesar = {
        isSystemUser = true;

        group = "mathesar";
        home = "/var/lib/podman-mathesar";

        autoSubUidGidRange = true;
        linger = false;
      };

      groups.mathesar = { };
    };

    virtualisation.oci-containers.containers = {
      mathesar = {
        image = "docker.io/mathesar/mathesar:${cfg.mathesar.version}";

        environment = {
          ALLOWED_HOSTS = "${cfg.mathesar.domain}";
          DJANGO_SETTINGS_MODULE = "config.settings.production";
          POSTGRES_USER = "mathesar";
          POSTGRES_DB = "mathesar";
          POSTGRES_HOST = "/var/run/postgresql";
        };

        environmentFiles = [ cfg.mathesar.envFile ];

        ports = [ "127.0.0.1:8280:8000" ];

        volumes = [
          "msar_media:/code/.media"
          "/var/run/postgresql:/var/run/postgresql"
        ];

        podman.user = "mathesar";
      };
    };
  };
}
