{ lib, pkgs, ... }:
let
  chunks = lib.importJSON ../chunks.json;
  assets = pkgs.callPackage ../pkgs/assets-joined { inherit (chunks) assets; };
  binaries = pkgs.pkgsi686Linux.callPackage ../pkgs/linux-binaries {
    depot = pkgs.callPackage ../pkgs/fetch-depot chunks.linux;
  };
  windowsBinaries = pkgs.callPackage ../pkgs/fetch-depot chunks.windows;
in
{

  name = "run-tf2ds";

  nodes = {
    server = {
      virtualisation.forwardPorts = [{
        from = "host";
        host.port = 27015;
        guest.port = 27015;
        proto = "udp";
      }];

      virtualisation.memorySize = 4 * 1024;

      networking.firewall.allowedUDPPorts = [ 27015 ];

      imports = [ ../nixos/tf2-dedicated-server.nix ];
      services.tf2-dedicated-server = {
        inherit binaries windowsBinaries assets;

        addons = [ ];

        instances.a = { };
      };
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("tf2ds@a.service")
  '';
}

