{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkMerge mkIf;

  cfg = config.tf2-spot;
in
{
  options = {
    tf2-spot = {
      tls = (mkEnableOption "") // { default = true; };

      toplevel = {
        enable = mkEnableOption "";
        domain = mkOption {
          type = types.str;
          default = "tf2.spot";
        };
      };

      fantasy = {
        enable = mkEnableOption "";

        domain = mkOption {
          type = types.str;
          default = "fantasy.tf2.spot";
        };
      };

      postgresql = {
        enable = mkEnableOption "";
      };

      sqitch = {
        enable = mkEnableOption "";
        apps = mkOption {
          type = with types; listOf str;
          default = [ "meta" "fantasy" ];
        };
      };

      postgrest = {
        enable = mkEnableOption "";

        domain = mkOption {
          type = types.str;
          default = "postgrest.tf2.spot";
        };

        jwtSecretFile = mkOption {
          type = with types; nullOr path;
          default = null;
        };
      };

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

  config = {
    security.acme = mkIf cfg.tls {
      certs = mkMerge [
        (mkIf cfg.toplevel.enable { "${cfg.toplevel.domain}".group = "caddy"; })
        (mkIf cfg.fantasy.enable { "${cfg.fantasy.domain}".group = "caddy"; })
        (mkIf cfg.postgrest.enable { "${cfg.postgrest.domain}".group = "caddy"; })
        (mkIf cfg.mathesar.enable { "${cfg.mathesar.domain}".group = "caddy"; })
      ];
    };

    services.caddy = mkIf
      (cfg.toplevel.enable || cfg.fantasy.enable
        || cfg.postgrest.enable || cfg.mathesar.enable)
      {
        enable = true;
        # openFirewall = true;

        virtualHosts = mkMerge [
          (mkIf cfg.toplevel.enable {
            "${cfg.toplevel.domain}" = {
              useACMEHost = mkIf cfg.tls "${cfg.toplevel.domain}";
              extraConfig = ''
                file_server {
                  root ${../../src/tf2.spot /* TODO: stop using path */}
                }
              '';
            };
          })

          (mkIf cfg.fantasy.enable {
            "${cfg.fantasy.domain}" = {
              useACMEHost = mkIf cfg.tls "${cfg.fantasy.domain}";
              extraConfig = ''
                respond 500
              '';
            };
          })

          (mkIf cfg.postgrest.enable {
            "${cfg.postgrest.domain}" = {
              useACMEHost = mkIf cfg.tls "${cfg.postgrest.domain}";
              extraConfig = ''
                reverse_proxy unix/${config.services.postgrest.settings.server-unix-socket}
              '';
            };
          })

          (mkIf cfg.mathesar.enable {
            "${cfg.mathesar.domain}" = {
              useACMEHost = mkIf cfg.tls "${cfg.mathesar.domain}";
              extraConfig = ''
                reverse_proxy http://localhost:8280
              '';
            };
          })
        ];
      };

    services.postgresql = mkIf cfg.postgresql.enable {
      enable = true;
      package = pkgs.postgresql_17;

      identMap = ''
        # map     # system   # role
        postgres  sqitch     sqitch
        postgres  postgrest  postgrest
        postgres  mathesar   mathesar
      '';

      ensureUsers = [
        {
          name = "sqitch";
          ensureClauses = {
            superuser = false;
          };
        }

        {
          name = "postgrest";
          ensureClauses = {
            "inherit" = false;
          };
        }

        {
          name = "mathesar";
          ensureDBOwnership = true;
          ensureClauses = {
            login = true;
          };
        }
      ];

      ensureDatabases = [ "mathesar" ];
    };

    services.postgrest = mkIf cfg.postgrest.enable {
      enable = true;

      settings = {
        db-uri = {
          user = "postgrest";
          dbname = "postgres";
        };

        db-schema = "fantasy_v0";
        db-anon-role = "fantasy_visitor";
      };

      jwtSecretFile = cfg.postgrest.jwtSecretFile;
    };

    users = mkIf cfg.mathesar.enable {
      users.mathesar = {
        group = "mathesar";
        isSystemUser = true;
        linger = true;
      };

      groups.mathesar = { };
    };

    virtualisation.oci-containers.containers = mkIf cfg.mathesar.enable {
      mathesar = {
        image = "docker.io/mathesar/mathesar:${cfg.mathesar.version}";

        environment = {
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
