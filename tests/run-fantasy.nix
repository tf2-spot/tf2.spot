{ module, ... }:
{ pkgs, ... }:
{
  name = "run-fantasy";

  nodes = {
    server = {
      imports = [ module ];

      tf2-spot = {
        fantasy.enable = true;
        fantasy.tls = false;
        postgresql.enable = true;
        postgrest.enable = true;
        postgrest.tls = false;
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

