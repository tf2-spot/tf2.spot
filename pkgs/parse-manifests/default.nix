{ writeShellApplication, eza, jq }:
writeShellApplication {
  name = "parse-manifests";

  runtimeInputs = [ eza jq ];
  runtimeEnv = {
    ASSETS_FILELIST = ./filelist-assets-no-vpk.txt;
    PARSE_MANIFESTS = ./parse-manifests.jq;
  };
  text = ''
    newest() { eza --sort=time -1 "$@" | head -1; }
    jq \
      --null-input \
      --rawfile assets_filelist $ASSETS_FILELIST \
      --rawfile assets  "$(newest manifests/manifest_232250_*.txt)" \
      --rawfile windows "$(newest manifests/manifest_232255_*.txt)" \
      --rawfile linux   "$(newest manifests/manifest_232256_*.txt)" \
      --from-file $PARSE_MANIFESTS
  '';
}
