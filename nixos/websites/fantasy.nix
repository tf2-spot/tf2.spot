{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot;
in
{
  options = {
    tf2-spot = {
      fantasy = {
        enable = mkEnableOption "";

        domain = mkOption {
          type = types.str;
          default = "fantasy.tf2.spot";
        };
      };
    };
  };

  config = mkIf cfg.fantasy.enable {
    security.acme.certs = mkIf cfg.tls {
      "${cfg.fantasy.domain}".group = "caddy";
    };

    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        "http${if cfg.tls then "s" else ""}://${cfg.fantasy.domain}" = {
          useACMEHost = mkIf cfg.tls "${cfg.fantasy.domain}";
          extraConfig = ''
            respond 500
          '';
        };
      };
    };
  };
}
