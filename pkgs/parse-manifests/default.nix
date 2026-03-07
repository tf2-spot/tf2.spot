{ lib
, writeShellApplication
, writeText
, eza
, jq
, manifests
}:
let
  fileArgs = lib.pipe manifests [
    builtins.attrValues
    (builtins.concatMap (x: x))
    (builtins.map (x: "  --rawfile ${x.depot} \"$(newest manifests/manifest_${x.depot}_*.txt)\" \\"))
    lib.unique
    (builtins.concatStringsSep "\n")
  ];
in
writeShellApplication {
  name = "parse-manifests";

  runtimeInputs = [ eza jq ];
  runtimeEnv = {
    MANIFESTS = writeText "manifests.json" (builtins.toJSON manifests);
    PARSE_MANIFESTS = ./parse-manifests.jq;
  };
  text = ''
    newest() { eza --sort=time -1 "$@" | head -1; }

    jq \
    ${fileArgs}
      --from-file $PARSE_MANIFESTS \
      "$MANIFESTS"
  '';
}
