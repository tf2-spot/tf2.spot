{ tf-assets, tf-linux, tf-windows }:
{ lib, pkgs, ... }:
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
        assets = tf-assets;
        binaries = tf-linux;
        windowsBinaries = tf-windows;

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

