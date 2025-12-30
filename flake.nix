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

      perSystem = { inputs', config, lib, pkgs, ... }:
        let
          chunks = lib.importJSON ./chunks.json;
        in
        {
          packages = {
            fetch-latest-manifests = pkgs.callPackage ./pkgs/fetch-latest-manifests { };
            parse-manifests = pkgs.callPackage ./pkgs/parse-manifests { };


            assets-joined = pkgs.callPackage ./pkgs/assets-joined {
              assets = chunks.assets;
            };

            windows-binaries = pkgs.callPackage ./pkgs/fetch-depot chunks.windows;
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
}
