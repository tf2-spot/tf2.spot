{ symlinkJoin
, linkFarm
, fetchDepot
, name
, date
, chunk
}:

let
  maybeSingle = builtins.partition (x: x.singleFile) chunk;
  singlesFarm =
    linkFarm "${name}-single-files"
      (map (x: { name = x.fileList; path = fetchDepot x; }) maybeSingle.right);
in

if builtins.length chunk == 1 && !(builtins.head chunk).singleFile then
  fetchDepot (builtins.head chunk)
else
  symlinkJoin {
    pname = name;
    version = date;
    paths = [ singlesFarm ] ++ (map fetchDepot maybeSingle.wrong);
  }
