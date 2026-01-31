{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.services.tf2classified-dedicated-server;

  searchPaths = [
    {
      keys = [ "game" "mod" "vgui" ];
      path = "${cfg.assets}/tf2classified/vpks/tf2c_assets.vpk";
    }
    {
      keys = [ "game" "mod" "vgui" ];
      path = "${cfg.assets}/tf2classified/vpks/mb2_tf_content.vpk";
    }
    {
      keys = [ "game" "mod" "vgui" ];
      path = "${cfg.assets}/tf2classified/vpks/mb2_shared_content.vpk";
    }
    {
      keys = [ "game" "mod" ];
      path = "${cfg.assets}/tf2classified/vpks/tf2c_overrides.vpk";
    }
    {
      keys = [ "game" "mod" "vgui" ];
      path = "${cfg.tf-assets}/tf/tf2_misc.vpk";
    }
    {
      keys = [ "game" "vgui" ];
      path = "${cfg.tf-assets}/hl2/hl2_misc.vpk";
    }
    {
      keys = [ "mod" "game" "mod_write" "game_write" "default_write_path" ];
      path = "tf2classified";
    }
    {
      keys = [ "gamebin" ];
      path = "${cfg.binaries}/tf2classified/bin";
    }
    {
      keys = [ "game" ];
      path = "${cfg.tf-assets}/hl2";
    }
    {
      keys = [ "game" "download" ];
      path = "tf2classified/download";
    }
  ];

  gameinfo =
    let
      paths =
        lib.concatMapStringsSep "\n      "
          ({ keys, path }: ''"${lib.concatStringsSep "+" keys}" "${path}"'')
          searchPaths;
    in
    pkgs.writeTextDir "gameinfo.txt" ''
      // This file was auto-generated

      #base "${cfg.assets}/tf2classified/gameinfo.txt"

      GameInfo {
        FileSystem {
          SearchPaths {
            ${paths}
          }
        }
      }
    '';
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
            HOME = "%S/tf2classified-ds/%i";
            LD_LIBRARY_PATH = "${cfg.binaries}/bin/linux64:${pkgs.ncurses5}/lib";
            ARG_BIND = "-ip 0.0.0.0";
            ARG_SDR = "-enablefakeip";
            ARG_EXTRA = "";
            CMD_PURE = "";
            CMD_MAP = "+map itemtest";
            CMD_EXTRA = "+status";
            TF2_ASSETS = cfg.assets;
            TF2_BINARIES = cfg.binaries;
            TF2_ADDONS = builtins.concatStringsSep ":" cfg.addons;
          };

          serviceConfig = {
            ExecStartPre = [
              "${pkgs.coreutils}/bin/mkdir -p \${HOME}/.steam"
              "${pkgs.coreutils}/bin/ln -snf ${cfg.steamworks}/linux64 \${HOME}/.steam/sdk64"
            ];

            ExecStart = ''
              ${cfg.binaries}/srcds_linux64 -game ${gameinfo} -tf_path ${cfg.tf-assets} ''${ARG_BIND} ''${ARG_SDR} $ARG_EXTRA ''${CMD_PURE} ''${CMD_MAP} $CMD_EXTRA
            '';

            DynamicUser = true;
            User = "tf2classified-ds-%i";

            StateDirectory = "tf2classified-ds/%i";
            WorkingDirectory = "%S/tf2classified-ds/%i";
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
