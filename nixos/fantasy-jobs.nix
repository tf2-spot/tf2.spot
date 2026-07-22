{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot.fantasy-jobs;
in
{
  options = {
    tf2-spot = {
      fantasy-jobs = {
        enable = mkEnableOption "";

        package = mkOption {
          type = types.raw;
        };

        envFile = mkOption {
          type = with types; nullOr str;
          default = null;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.timers.fantasy-jobs = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "minutely";
        Unit = "fantasy-jobs.service";
      };
    };

    systemd.services.fantasy-jobs = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];

      environment = {
        PGUSER = "fantasy_janitor";
        PGDATABASE = "postgres";
      };

      serviceConfig = {
        Type = "oneshot";

        ExecStart = "${cfg.package}/bin/fantasy-jobs";

        DynamicUser = true;

        EnvironmentFile = cfg.envFile;
      };
    };
  };
}

