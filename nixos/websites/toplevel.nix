{ lib, config, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf;

  cfg = config.tf2-spot;
in
{
  options = {
    tf2-spot = {
      toplevel = {
        enable = mkEnableOption "";
        domain = mkOption {
          type = types.str;
          default = "tf2.spot";
        };
      };
    };
  };

  config = mkIf cfg.toplevel.enable {
    security.acme.certs = mkIf cfg.tls {
      "${cfg.toplevel.domain}".group = "caddy";
    };

    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        "http${if cfg.tls then "s" else ""}://${cfg.toplevel.domain}" = {
          useACMEHost = mkIf cfg.tls "${cfg.toplevel.domain}";
          extraConfig = ''
            file_server {
              root ${../../pkgs/toplevel-website /* TODO: stop using path */}
            }
          '';
        };
      };
    };
  };
}
