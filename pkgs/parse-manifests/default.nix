{ writeShellApplication, jq }:
writeShellApplication {
  name = "parse-manifests";

  runtimeInputs = [ jq ];
  runtimeEnv = {
    ASSETS_FILELIST = ./filelist-assets-no-vpk.txt;
    PARSE_MANIFESTS = ./parse-manifests.jq;
  };
  text = ''
    jq \
      --null-input \
      --rawfile assets_filelist $ASSETS_FILELIST \
      --rawfile assets  manifests/manifest_232250_*.txt \
      --rawfile windows manifests/manifest_232255_*.txt \
      --rawfile linux   manifests/manifest_232256_*.txt \
      --from-file $PARSE_MANIFESTS
  '';
}
