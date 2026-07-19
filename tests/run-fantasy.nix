{ module, ... }:
{ pkgs, ... }:
{
  name = "run-fantasy";

  nodes = {
    server = {
      imports = [ module ];

      tf2-spot = {
        tls = false;
        fantasy.enable = true;
        postgresql.enable = true;
        postgrest.enable = true;
        sqitch.enable = true;
        sqitch.target = "db:pg://sqitch@/postgres";
      };
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("default.target")
  '';
}

