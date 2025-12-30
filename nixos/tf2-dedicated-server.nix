{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.services.tf2-dedicated-server;

  lowerdir = builtins.concatStringsSep ":" (cfg.addons ++ [ cfg.binaries cfg.assets ]);

  pre = pkgs.writeShellApplication {
    name = "tf2ds-pre-mount-overlay";
    text = ''
      inst=$1
      path=$2
      name=$(systemd-escape --path "$path")

      systemctl edit --runtime --full --force --stdin "$name".mount << END
      [Unit]
      PartOf=tf2ds@$inst.service

      [Mount]
      Type=overlay
      What=overlay
      Where=$path
      Options=${builtins.concatStringsSep "," [
        "upperdir=%S/private/tf2ds/$inst"
        "workdir=%S/private/tf2ds/.$inst"
        "lowerdir=${lowerdir}"
      ]}
      END

      systemctl start "$name".mount

      chown "tf2ds-$inst":"tf2ds-$inst" "$path"
    '';
  };
in
{
  options = {
    services.tf2-dedicated-server = {
      binaries = mkOption {
        type = types.package;
      };

      assets = mkOption {
        type = types.package;
      };

      addons = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };

      instances = mkOption {
        type = types.lazyAttrsOf (types.submodule {
          options = { };
        });

        default = { };
      };
    };
  };

  config = {
    users.groups.tf2ds = { };

    systemd.services = lib.mkMerge (
      [{
        "tf2ds@" = {
          description = "%i — Team Fortress 2 Dedicated Server";

          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          environment = {
            HOME = "%t/tf2ds/%i/.home";
            LD_LIBRARY_PATH = "%t/tf2ds/%i/bin:${pkgs.pkgsi686Linux.ncurses5}/lib";
            ARG_BIND = "-ip 0.0.0.0";
            ARG_SDR = "-enablefakeip";
            ARG_EXTRA = "";
            CMD_PURE = "+sv_pure 2";
            CMD_MAP = "+map itemtest";
            CMD_EXTRA = "";
          };

          serviceConfig = {
            ExecStartPre = "+${lib.getExe pre} %i %t/tf2ds/%i";
            ExecStart = ''
              %t/tf2ds/%i/srcds_linux -game tf ''${ARG_BIND} ''${ARG_SDR} $ARG_EXTRA ''${CMD_PURE} ''${CMD_MAP} $CMD_EXTRA
            '';

            DynamicUser = true;
            User = "tf2ds-%i";

            RuntimeDirectory = "tf2ds/%i";
            StateDirectory = "tf2ds/%i .tf2ds/%i";
            WorkingDirectory = "%t/tf2ds/%i";
          };
        };
      }]
      ++
      lib.mapAttrsToList
        (name: _: {
          "tf2ds@${name}" = {
            overrideStrategy = "asDropin";
            wantedBy = [ "multi-user.target" ];
          };
        })
        cfg.instances
    );
  };


}
