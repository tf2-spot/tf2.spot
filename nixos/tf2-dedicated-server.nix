{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.services.tf2-dedicated-server;

  pre = pkgs.writeShellApplication {
    name = "tf2ds-pre-mount-overlay";
    text = ''
      inst=$1
      name=$(systemd-escape --path "$RUNTIME_DIRECTORY")
      upperdir=$(echo "$STATE_DIRECTORY" | cut -d ':' -f 1)
      workdir=$(echo "$STATE_DIRECTORY" | cut -d ':' -f 2)
      lowerdir=$(printf '%s:' "$TF2_ADDONS" "$TF2_BINARIES" "$TF2_ASSETS" | sed 's/::+/:/; s/^://; s/:$//')

      systemctl edit --runtime --full --force --stdin "$name".mount << END
      [Unit]
      PartOf=tf2ds@$inst.service

      [Mount]
      Type=overlay
      What=overlay
      Where=$RUNTIME_DIRECTORY
      Options=upperdir=$upperdir,workdir=$workdir,lowerdir=$lowerdir
      END

      systemctl start "$name".mount

      chown "tf2ds-$inst":"tf2ds-$inst" "$RUNTIME_DIRECTORY"
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
            TF2_ASSETS = cfg.assets;
            TF2_BINARIES = cfg.binaries;
            TF2_ADDONS = builtins.concatStringsSep ":" cfg.addons;
          };

          serviceConfig = {
            ExecStartPre = "+${lib.getExe pre} %i";
            ExecStart = ''
              %t/tf2ds/%i/srcds_linux -game tf ''${ARG_BIND} ''${ARG_SDR} $ARG_EXTRA ''${CMD_PURE} ''${CMD_MAP} $CMD_EXTRA
            '';

            DynamicUser = true;
            User = "tf2ds-%i";

            RuntimeDirectory = "tf2ds/%i";
            StateDirectory = "tf2ds/%i tf2ds/.%i";
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
