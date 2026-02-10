{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, obs-studio
, dlib
, opencv
}:

stdenv.mkDerivation rec {
  pname = "obs-face-tracker";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "norihiro";
    repo = "obs-face-tracker";
    rev = "v${version}";
    sha256 = "sha256-046sz4qklw8c7wip6cdmgb7g3q4sv82d0mdhm1q6bzyyl5l403dn=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    obs-studio
    dlib
    opencv
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/obs-plugins
    mkdir -p $out/share/obs/obs-plugins/obs-face-tracker

    cp obs-face-tracker.so $out/lib/obs-plugins/
    cp -r ../data $out/share/obs/obs-plugins/obs-face-tracker/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Face tracking plugin for OBS Studio";
    homepage = "https://github.com/norihiro/obs-face-tracker";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
