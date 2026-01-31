{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    spire = {
      url = "git+https://codeberg.org/spire/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { inputs', config, lib, pkgs, ... }: {
        options = {
          lib = lib.mkOption { type = lib.types.raw; };
        };

        config = {
          lib = {
            manifests = {
              steamworks-linux = [{ app = "1007"; depot = "1006"; }];

              tf-windows = [{ app = "232250"; depot = "232255"; }];
              tf-linux = [{ app = "232250"; depot = "232256"; }];
              tf-assets = [
                { app = "232250"; depot = "232250"; fileList = builtins.readFile ./files-tf-assets.txt; }
                { app = "232250"; depot = "232250"; startsWith = "hl2/hl2_misc_"; }
                { app = "232250"; depot = "232250"; startsWith = "tf/tf2_misc_"; }
              ];

              tf2classified-windows = [{ app = "3557020"; depot = "3557022"; }];
              tf2classified-linux = [{ app = "3557020"; depot = "3557023"; }];
              tf2classified-assets = [
                { app = "3557020"; depot = "3545061"; fileList = builtins.readFile ./files-tf2classified-assets.txt; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/vpks/tf2c_assets_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/vpks/tf2c_overrides_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/4arena_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/4dom_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/4plr_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/arena_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/cp_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/ctf_"; }
                { app = "3557020"; depot = "3545061"; startsWith = "tf2classified/maps/dom_"; }
                { app = "3557020"; depot = "3545064"; }
              ];
            };

            chunks = lib.importJSON ./chunks.json;

            fetchDepot = pkgs.callPackage ./pkgs/fetch-depot;

            fetchJoinChunk = { name, date, chunk }:
              pkgs.callPackage ./pkgs/fetch-join-chunk {
                inherit name date chunk;
                inherit (config.lib) fetchDepot;
              };
          };

          packages = {
            fetch-latest-manifests = pkgs.callPackage ./pkgs/fetch-latest-manifests { inherit (config.lib) manifests; };
            parse-manifests = pkgs.callPackage ./pkgs/parse-manifests { inherit (config.lib) manifests; };
            prefetch-missing = pkgs.callPackage ./pkgs/prefetch-missing { };

            steamworks-linux = config.lib.fetchDepot (builtins.head config.lib.chunks.steamworks-linux);

            tf-assets = config.lib.fetchJoinChunk {
              name = "tf2ds-assets";
              date = config.lib.chunks.dates."232250";
              chunk = config.lib.chunks.tf-assets;
            };

            tf-linux = pkgs.pkgsi686Linux.callPackage ./pkgs/tf-linux-binaries {
              date = config.lib.chunks.dates."232256";
              depot = config.lib.fetchDepot (builtins.head config.lib.chunks.tf-linux);
            };

            tf-windows = config.lib.fetchDepot (builtins.head config.lib.chunks.tf-windows);

            tf2classified-assets = config.lib.fetchJoinChunk {
              name = "tf2classified-ds-assets";
              date = config.lib.chunks.dates."3545061";
              chunk = config.lib.chunks.tf2classified-assets;
            };

            tf2classified-linux-raw = config.lib.fetchDepot (builtins.head config.lib.chunks.tf2classified-linux);
            tf2classified-linux = pkgs.callPackage ./pkgs/tf2classified-linux-binaries {
              date = config.lib.chunks.dates."3557023";
              depot = config.lib.fetchDepot (builtins.head config.lib.chunks.tf2classified-linux);
            };
          };

          checks = {
            run-tf2ds = pkgs.testers.runNixOSTest (
              import ./tests/run-tf2ds.nix {
                inherit (config.packages) tf-assets tf-linux tf-windows;
              }
            );

            run-tf2classified-ds = pkgs.testers.runNixOSTest (
              import ./tests/run-tf2classified-ds.nix {
                inherit (config.packages) steamworks-linux tf-assets tf2classified-assets tf2classified-linux;
              }
            );
          };

          devShells.plugins =
            let
              inherit (inputs'.spire.packages) sourcepawn;
            in
            pkgs.mkShell {
              nativeBuildInputs = [
                (sourcepawn.buildEnv [
                  sourcepawn.includes.sourcemod
                ])
              ];
            };
        };
      };
    };
}
