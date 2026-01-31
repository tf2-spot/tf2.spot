{ stdenv
, autoPatchelfHook
, curlWithGnuTls
, SDL2
, openal
, bzip2
, libpng
, libvdpau
, libx11
, libva
, libdrm
, expat
, glib
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
    curlWithGnuTls
    SDL2
    openal
    bzip2
    libpng
    libvdpau
    libx11
    libva
    libdrm
    expat
    glib
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $src/. $out

    chmod +x $out/srcds_linux64

    runHook postInstall
  '';
}
