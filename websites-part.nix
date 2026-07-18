{ lib, inputs, ... }:
let
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  editableOverlay = workspace.mkEditablePyprojectOverlay {
    root = "$REPO_ROOT";
  };
in
{
  flake.nixosModules = {
    websites = ./nixos/websites;
  };

  perSystem = { pkgs, ... }:
    let
      pythonSet = (pkgs.callPackage inputs.pyproject-nix.build.packages {
        python = pkgs.python3;
      }).overrideScope (
        lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.wheel
          overlay
        ]
      );

      venv = pythonSet.mkVirtualEnv "application-env" workspace.deps.default;
      devVenv = (pythonSet.overrideScope editableOverlay).mkVirtualEnv "dev-env" workspace.deps.all;

      inherit (pkgs.callPackages inputs.pyproject-nix.build.util { }) mkApplication;
    in
    {
      packages = {
        # fantasy-website = mkApplication {
        #   inherit venv;
        #   package = pythonSet.fantasy-website;
        # };

        fantasy-jobs = mkApplication {
          inherit venv;
          package = pythonSet.fantasy-jobs;
        };
      };

      devShells = {
        websites = pkgs.mkShell {
          packages = [
            pkgs.postgresql
            pkgs.sqitchPg

            devVenv
            pkgs.uv
            pkgs.ruff
            pkgs.ty

            pkgs.tailwindcss_4
            pkgs.watchman
          ];

          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = pythonSet.python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            unset PYTHONPATH
            export REPO_ROOT=$(git rev-parse --show-toplevel)
          '';
        };
      };

      checks = {
        run-fantasy = pkgs.testers.runNixOSTest ./tests/run-fantasy.nix;
      };
    };
}
