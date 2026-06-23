{ stdenvNoCC
, stdenv
, lib
, dpkg
, autoPatchelfHook
, makeWrapper
, fetchurl
, alsa-lib
, openssl
, udev
, libglvnd
, libX11
, libXcursor
, libXi
, libXrandr
, libXfixes
, libpulseaudio
, libva
, ffmpeg_7
, libpng
, libjpeg8
, curl
, vulkan-loader
, zenity
}:

let
  pname = "parsec";
  version = "150-97c";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://builds.parsec.app/package/parsec-linux.deb";
    sha256 = "sha256-8Wkbo6l1NGBPX2QMJszq+u9nLM96tu7WYRTQq6/CzM8=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    stdenv.cc.cc
    libglvnd
    libX11
  ];

  runtimeDependenciesPath = lib.makeLibraryPath [
    stdenv.cc.cc
    libglvnd
    openssl
    udev
    alsa-lib
    libpulseaudio
    libva
    ffmpeg_7
    libpng
    libjpeg8
    curl
    libX11
    libXcursor
    libXi
    libXrandr
    libXfixes
    vulkan-loader
  ];

  dontAutoPatchelf = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    dpkg-deb -x $src $out
    mv $out/usr/* $out
    rm -rf $out/usr

    autoPatchelf -- $out/bin

    wrapProgram $out/bin/parsecd \
      --prefix LD_LIBRARY_PATH : "$runtimeDependenciesPath" \
      --prefix PATH : "${lib.makeBinPath [ zenity ]}" \
      --run '
        if [[ ! -e "$HOME/.parsec/appdata.json" ]]; then
          mkdir -p "$HOME/.parsec"
          cp --no-preserve=mode,ownership,timestamps '"$out/share/parsec/skel/*"' "$HOME/.parsec/"
        fi
      '

    ln -s $out/bin/parsecd $out/bin/parsec

    substituteInPlace $out/share/applications/parsecd.desktop \
      --replace "/usr/bin/parsecd" "parsecd" \
      --replace "/usr/share/icons" "$out/share/icons"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Remote desktop streaming service client";
    homepage = "https://parsec.app/";
    changelog = "https://parsec.app/changelog";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "parsecd";
  };
}
