{ symlinkJoin
, linkFarm
, fetchDepot
, assets
}:
let
  maybeSingle = builtins.partition (x: x.singleFile) assets;
  singlesFarm =
    linkFarm "tf2-dedicated-server-assets-single-files"
      (map (x: { name = x.fileList; path = fetchDepot x; }) maybeSingle.right);
in
symlinkJoin {
  pname = "tf2-dedicated-server-assets";
  version = (builtins.head assets).date;
  paths = [ singlesFarm ] ++ (map fetchDepot maybeSingle.wrong);
}
