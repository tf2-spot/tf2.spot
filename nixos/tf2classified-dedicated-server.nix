{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.services.tf2classified-dedicated-server;

  pre = pkgs.writeShellApplication {
    name = "tf2classified-ds-pre-mount-overlay";
    text = ''
      unit=$1
      name=$(systemd-escape --path "$RUNTIME_DIRECTORY")
      upperdir=$(echo "$STATE_DIRECTORY" | cut -d ':' -f 1)
      workdir=$(echo "$STATE_DIRECTORY" | cut -d ':' -f 2)
      lowerdir=$(printf '%s:' "$TF2_ADDONS" "$TF2_BINARIES" "$TF2_ASSETS" | sed 's/::+/:/; s/^://; s/:$//')

      systemctl edit --runtime --full --force --stdin "$name".mount << END
      [Unit]
      PartOf=$unit

      [Mount]
      Type=overlay
      What=overlay
      Where=$RUNTIME_DIRECTORY
      Options=upperdir=$upperdir,workdir=$workdir,lowerdir=$lowerdir
      END

      systemctl start "$name".mount

      chown "$USER":"$USER" "$RUNTIME_DIRECTORY"
    '';
  };
in
{
  options = {
    services.tf2classified-dedicated-server = {
      steamworks = mkOption {
        type = types.package;
      };

      binaries = mkOption {
        type = types.package;
      };

      assets = mkOption {
        type = types.package;
      };

      tf-assets = mkOption {
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
    systemd.services = lib.mkMerge (
      [{
        "tf2classified-ds@" = {
          description = "%i — Team Fortress 2 Classified Dedicated Server";

          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          environment = {
            HOME = "%t/tf2classified-ds/%i/.home";
            # LD_LIBRARY_PATH = "%t/tf2classified-ds/%i/bin/linux64";
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
            ExecStartPre = [
              "+${lib.getExe pre} tf2classified-ds@%i.service"
              "${pkgs.coreutils}/bin/mkdir -p \${HOME}/.steam"
              "${pkgs.coreutils}/bin/ln -sf ${cfg.steamworks}/linux64 \${HOME}/.steam/sdk64"
            ];
            ExecStart = ''
              /bin/sh ./srcds.sh -tf_path ${cfg.tf-assets} ''${ARG_BIND} ''${ARG_SDR} $ARG_EXTRA ''${CMD_PURE} ''${CMD_MAP} $CMD_EXTRA
            '';

            DynamicUser = true;
            User = "tf2classified-ds-%i";

            RuntimeDirectory = "tf2classified-ds/%i";
            StateDirectory = "tf2classified-ds/%i tf2classified-ds/.%i";
            WorkingDirectory = "%t/tf2classified-ds/%i";
          };
        };
      }]
      ++ lib.mapAttrsToList
        (name: _: {
          "tf2classified-ds@${name}" = {
            overrideStrategy = "asDropin";
            wantedBy = [ "multi-user.target" ];
          };
        })
        cfg.instances
    );
  };


}
