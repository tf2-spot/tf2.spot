{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.tf2-spot;
in
{
  options = {
    tf2-spot = {
      postgresql = {
        enable = mkEnableOption "";
      };
    };
  };

  config = mkIf cfg.postgresql.enable {
    services.postgresql = {
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
  };
}
