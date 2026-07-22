{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot.postgrest;
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

        tls = mkEnableOption "" // { default = true; };

        url = mkOption {
          type = types.str;
          internal = true;
          default = "http${lib.optionalString cfg.tls "s"}://${cfg.domain}";
        };

        jwtSecretFile = mkOption {
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

      jwtSecretFile = cfg.jwtSecretFile;
    };
  };
}
