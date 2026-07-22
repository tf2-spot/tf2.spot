{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot.sqitch;
in
{
  options = {
    tf2-spot = {
      sqitch = {
        enable = mkEnableOption "";

        target = mkOption {
          type = types.str;
          default = "db:pg://sqitch@/postgres";
        };

        userConfig = mkOption {
          type = types.str;
          default = "";
        };

        envFile = mkOption {
          type = with types; nullOr str;
          default = null;
        };

        projects = mkOption {
          type = with types; listOf str;
          default = [ "meta" "fantasy" ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.sqitch = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.sqitchPg pkgs.postgresql ];

      preStart = ''
        ${pkgs.envsubst}/bin/envsubst \
          -o /run/sqitch/sqitch.conf \
          -i ${pkgs.writeText "sqitch.conf" cfg.userConfig}
      '';

      script = lib.concatMapStringsSep "\n"
        (project: ''
          sqitch --chdir '${../sqitch /* TODO: stop using path */}/${project}' deploy
        '')
        cfg.projects;

      environment = {
        SQITCH_USER_CONFIG = "/run/sqitch/sqitch.conf";
        SQITCH_TARGET = cfg.target;
        SQITCH_FULLNAME = "sqitch service";
        SQITCH_EMAIL = "sqitch.service@tf2.spot";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        DynamicUser = true;
        RuntimeDirectory = "sqitch";
        RuntimeDirectoryMode = "0700";

        EnvironmentFile = cfg.envFile;
      };
    };
  };
}
