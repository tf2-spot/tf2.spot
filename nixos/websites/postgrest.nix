{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot;
in
{
  options = {
    tf2-spot = {
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
    };
  };

  config = mkIf cfg.postgrest.enable {
    security.acme.certs = mkIf cfg.tls {
      "${cfg.postgrest.domain}".group = "caddy";
    };

    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        "http${if cfg.tls then "s" else ""}://${cfg.postgrest.domain}" = {
          useACMEHost = mkIf cfg.tls "${cfg.postgrest.domain}";
          extraConfig = ''
            reverse_proxy unix/${config.services.postgrest.settings.server-unix-socket}
          '';
        };
      };
    };

    services.postgrest = {
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
  };
}
