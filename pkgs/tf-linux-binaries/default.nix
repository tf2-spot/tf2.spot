{ stdenv
, autoPatchelfHook
, curlWithGnuTls
, depot
, date
}:
stdenv.mkDerivation {
  pname = "tf2ds-binaries";
  version = date;

  src = depot;

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    (curlWithGnuTls.overrideAttrs (final: prev: {
      patches = (prev.patches or [ ]) ++ [ ./curl-symbol-downgrade.patch ];
    }))
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $src/. $out

    runHook postInstall
  '';
}
