{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot.mathesar;
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

        tls = mkEnableOption "" // { default = true; };

        url = mkOption {
          type = types.str;
          internal = true;
          default = "http${lib.optionalString cfg.tls "s"}://${cfg.domain}";
        };

        envFile = mkOption {
          type = with types; nullOr path;
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
        image = "docker.io/mathesar/mathesar:${cfg.version}";

        environment = {
          ALLOWED_HOSTS = "${cfg.domain}";
          DJANGO_SETTINGS_MODULE = "config.settings.production";
          POSTGRES_USER = "mathesar";
          POSTGRES_DB = "mathesar";
          POSTGRES_HOST = "/var/run/postgresql";
        };

        environmentFiles = [ cfg.envFile ];

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
