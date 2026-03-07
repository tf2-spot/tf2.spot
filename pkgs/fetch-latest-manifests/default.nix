{ lib
, writeShellApplication
, depotdownloader
, manifests
}:

writeShellApplication {
  name = "fetch-latest-manifests";

  runtimeInputs = [ depotdownloader ];

  text = lib.pipe manifests [
    builtins.attrValues
    (builtins.concatMap (x: x))
    (builtins.map (lib.getAttrs [ "app" "depot" ]))
    lib.unique
    (builtins.map (x: "DepotDownloader -app ${x.app} -depot ${x.depot} -manifest-only -dir manifests"))
    (builtins.concatStringsSep "\n")
  ];
}
