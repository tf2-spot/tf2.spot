{ pkgs, ... }:
{
  name = "run-fantasy";

  nodes = {
    server = {
      imports = [ ../nixos/websites ];

      tf2-spot = {
        tls = false;

        fantasy.enable = true;
        postgresql.enable = true;
        postgrest.enable = true;
        sqitch.enable = true;
      };
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("default.target")
  '';
}

