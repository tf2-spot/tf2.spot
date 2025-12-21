{ symlinkJoin
, linkFarm
, callPackage
, assets
}:
let
  fetchDepot = callPackage ../fetch-depot;
  maybeSingle = builtins.partition (x: x.singleFile) assets;
  singlesFarm =
    linkFarm "assets-single-files"
      (map (x: { name = x.fileList; path = fetchDepot x; }) maybeSingle.right);
in
symlinkJoin {
  pname = "tf2-dedicated-server-assets";
  version = (builtins.head assets).date;
  paths = [ singlesFarm ] ++ (map fetchDepot maybeSingle.wrong);
}
