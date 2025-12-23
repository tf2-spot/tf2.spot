{ stdenv
, autoPatchelfHook
, curlWithGnuTls
, depot
}:
stdenv.mkDerivation {
  name = "tf2ds-binaries";

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
