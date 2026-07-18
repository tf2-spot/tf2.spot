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

        target = mkOption {
          type = types.str;
        };

        userConfig = mkOption {
          type = types.str;
        };

        envFile = mkOption {
          type = types.str;
        };

        projects = mkOption {
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
        openFirewall = true;

        virtualHosts =
          let
            d =
              if cfg.tls then
                domain: "https://${domain}"
              else
                domain: "http://${domain}";
          in
          mkMerge [
            (mkIf cfg.toplevel.enable {
              "${d cfg.toplevel.domain}" = {
                useACMEHost = mkIf cfg.tls "${cfg.toplevel.domain}";
                extraConfig = ''
                  file_server {
                    root ${../../pkgs/toplevel-website /* TODO: stop using path */}
                  }
                '';
              };
            })

            (mkIf cfg.fantasy.enable {
              "${d cfg.fantasy.domain}" = {
                useACMEHost = mkIf cfg.tls "${cfg.fantasy.domain}";
                extraConfig = ''
                  respond 500
                '';
              };
            })

            (mkIf cfg.postgrest.enable {
              "${d cfg.postgrest.domain}" = {
                useACMEHost = mkIf cfg.tls "${cfg.postgrest.domain}";
                extraConfig = ''
                  reverse_proxy unix/${config.services.postgrest.settings.server-unix-socket}
                '';
              };
            })

            (mkIf cfg.mathesar.enable {
              "${d cfg.mathesar.domain}" = {
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

      authentication = ''
        local all all peer map=postgres
      '';

      identMap = ''
        # map     # system   # role
        postgres  sqitch     sqitch
        postgres  postgrest  postgrest
        postgres  mathesar   mathesar
        postgres  mathesar   fantasy_admin
      '';

      initialScript = pkgs.writeText "init.sql" ''
        create user mathesar login;
        grant connect, create on database postgres to mathesar;
      '';

      ensureUsers = [
        {
          name = "sqitch";
          ensureClauses = {
            superuser = true;
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

    systemd.services.sqitch = mkIf cfg.sqitch.enable {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.sqitchPg pkgs.postgresql ];

      preStart = ''
        ${pkgs.envsubst}/bin/envsubst \
          -o /run/sqitch/sqitch.conf \
          -i ${pkgs.writeText "sqitch.conf" cfg.sqitch.userConfig}
      '';

      script = lib.concatMapStringsSep "\n"
        (project: ''
          sqitch --chdir '${../../sqitch /* TODO: stop using path */}/${project}' deploy
        '')
        cfg.sqitch.projects;

      environment = {
        SQITCH_USER_CONFIG = "/run/sqitch/sqitch.conf";
        SQITCH_TARGET = cfg.sqitch.target;
        SQITCH_FULLNAME = "sqitch service";
        SQITCH_EMAIL = "sqitch.service@tf2.spot";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        DynamicUser = true;
        RuntimeDirectory = "sqitch";
        RuntimeDirectoryMode = "0700";

        EnvironmentFile = cfg.sqitch.envFile;
      };
    };

    systemd.services.podman-mathesar = mkIf cfg.mathesar.enable {
      # Mathesar gets stuck with no socket when postgresql restarts,
      # make it stop when postgresql stops.
      after = [ "postgresql.service" ];
      bindsTo = [ "postgresql.service" ];
    };

    users = mkIf cfg.mathesar.enable {
      users.mathesar = {
        isSystemUser = true;

        group = "mathesar";
        home = "/var/lib/podman-mathesar";

        autoSubUidGidRange = true;
        linger = false;
      };

      groups.mathesar = { };
    };

    virtualisation.oci-containers.containers = mkIf cfg.mathesar.enable {
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
