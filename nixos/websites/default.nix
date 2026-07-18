{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./fantasy.nix
    ./mathesar.nix
    ./postgresql.nix
    ./postgrest.nix
    ./sqitch.nix
    ./toplevel.nix
  ];

  options = {
    tf2-spot = {
      tls = (mkEnableOption "") // { default = true; };
    };
  };
}
