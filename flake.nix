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

      flake.nixosModules = {
        fantasy = ./nixos/fantasy;
      };

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
          };

          checks = {
            run-tf2ds = pkgs.testers.runNixOSTest (
              import ./tests/run-tf2ds.nix {
                inherit (config.packages) tf-assets tf-linux tf-windows;
              }
            );
          };

          devShells = {
            fantasy = pkgs.mkShell {
              packages = [
                pkgs.postgresql
                pkgs.sqitchPg

                # tmp
                pkgs.podman-compose
              ];
            };

            plugins = pkgs.mkShell {
              nativeBuildInputs =
                let
                  inherit (inputs'.spire.packages) sourcepawn;
                in
                [
                  (sourcepawn.buildEnv [
                    sourcepawn.includes.sourcemod
                  ])
                ];
            };
          };
        };
      };
    };
}
