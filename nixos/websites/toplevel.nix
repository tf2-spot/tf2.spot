{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot.toplevel;
in
{
  options = {
    tf2-spot = {
      toplevel = {
        enable = mkEnableOption "";

        package = mkOption {
          type = types.raw;
        };

        domain = mkOption {
          type = types.str;
          default = "tf2.spot";
        };

        tls = mkEnableOption "" // { default = true; };

        url = mkOption {
          type = types.str;
          internal = true;
          default = "http${lib.optionalString cfg.tls "s"}://${cfg.domain}";
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
            file_server {
              root ${cfg.package}
            }
          '';
        };
      };
    };
  };
}
