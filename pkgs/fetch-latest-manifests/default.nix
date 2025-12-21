{ writeShellApplication, depotdownloader }:
writeShellApplication {
  name = "fetch-latest-manifests";

  runtimeInputs = [ depotdownloader ];

  text = ''
    DepotDownloader -app 232250 -depot 232250 -manifest-only -dir manifests
    DepotDownloader -app 232250 -depot 232255 -manifest-only -dir manifests
    DepotDownloader -app 232250 -depot 232256 -manifest-only -dir manifests
  '';
}
