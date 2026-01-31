{ stdenv
, autoPatchelfHook
, auto-patchelf
, curlWithGnuTls
, curl
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
    auto-patchelf
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

    mkdir tmp
    cp -r $src/. tmp

    chmod -R +w tmp

    mv tmp/bin/linux64/curlmgr.so .

    auto-patchelf --libs "${stdenv.cc.cc.lib}/lib" "${curl.out}/lib" --ignore-missing=libtier0.so --paths curlmgr.so

    mv tmp $out
    mv curlmgr.so $out/bin/linux64/

    chmod +x $out/srcds_linux64

    runHook postInstall
  '';
}
