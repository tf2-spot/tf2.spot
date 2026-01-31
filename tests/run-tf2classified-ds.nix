{ steamworks-linux, tf-assets, tf2classified-assets, tf2classified-linux }:
{ lib, pkgs, ... }:
{

  name = "run-tf2classified-ds";

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

      imports = [ ../nixos/tf2classified-dedicated-server.nix ];
      services.tf2classified-dedicated-server = {
        steamworks = steamworks-linux;
        binaries = tf2classified-linux;
        assets = tf2classified-assets;
        tf-assets = tf-assets;

        addons = [ ];

        instances.a = { };
      };
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("tf2classified-ds@a.service")
  '';
}

