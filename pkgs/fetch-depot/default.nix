{ lib
, runCommand
, depotdownloader
, cacert
, app
, depot
, manifest
, fileList
, hash
, singleFile ? false
, date ? null
}:

runCommand "depot-${depot}.${manifest}"
{
  buildInputs = [
    depotdownloader
  ];

  env = {
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    inherit app depot manifest;
  };

  inherit fileList;
  passAsFile = [ "fileList" ];

  outputHash = lib.throwIf (hash == null) "fetch-depot requires a hash" hash;
  outputHashAlgo = if singleFile then "sha1" else "sha256";
  outputHashMode = if singleFile then "flat" else "recursive";
}
  ''
    HOME=$(mktemp -d) \
    DepotDownloader \
      -app $app \
      -depot $depot \
      -manifest $manifest \
      ${lib.optionalString (fileList != null) "-filelist $fileListPath"} \
      -dir ./out

    rm -rf ./out/.DepotDownloader

    ${if singleFile then ''
      mv ./out/${fileList} $out
    '' else ''
      mv ./out $out
    ''}
  ''
