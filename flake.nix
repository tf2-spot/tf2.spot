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
            fetchDepot = pkgs.callPackage ./pkgs/fetch-depot;
            chunks = lib.importJSON ./chunks.json;
          };

          packages = {
            fetch-latest-manifests = pkgs.callPackage ./pkgs/fetch-latest-manifests { };
            parse-manifests = pkgs.callPackage ./pkgs/parse-manifests { };
            prefetch-missing = pkgs.callPackage ./pkgs/prefetch-missing { };

            assets-joined = pkgs.callPackage ./pkgs/assets-joined {
              inherit (config.lib.chunks) date assets;
              fetchDepot = config.lib.fetchDepot;
            };

            linux-binaries = pkgs.pkgsi686Linux.callPackage ./pkgs/linux-binaries {
              inherit (config.lib.chunks) date;
              depot = config.lib.fetchDepot config.lib.chunks.linux;
            };

            windows-binaries = config.lib.fetchDepot config.lib.chunks.windows;
          };

          checks = {
            run-tf2ds = pkgs.testers.runNixOSTest ./tests/run-tf2ds.nix;
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
