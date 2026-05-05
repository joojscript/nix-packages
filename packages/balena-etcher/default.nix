# https://github.com/balena-io/etcher/releases/download/v1.7.9/balenaEtcher-1.7.9-x64.AppImage

{ appimageTools
, autoPatchelfHook
, fetchurl
, lib
, stdenv
, glib
, gtk3
, libxshmfence
, libxcb
, libxkbcommon
, libxcursor
, libxrandr
, libxinerama
, libXi
, libxext
, libx11
, mesa
}:

let
  pname = "balena-etcher";
  version = "1.7.9";
  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
    sha256 = "0kq2arf1q7nqr2m6cqhvky6cfbhlzdr7fxiwlgiprsppki89rdxx";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    glib
    gtk3
    libxshmfence
    libxcb
    libxkbcommon
    libxcursor
    libxrandr
    libxinerama
    libXi
    libxext
    libx11
    mesa
  ];

  extraInstallCommands = ''
    # Create desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/balena-etcher.desktop << EOF
[Desktop Entry]
Type=Application
Name=Balena Etcher
Exec=$out/bin/balena-etcher %F
Icon=balena-etcher
Comment=Flash OS images to SD cards & USB drives
Categories=Utility;
EOF

    # Copy icon if available (AppImage might have it)
    # Assuming the AppImage extracts to have an icon
    if [ -f $out/share/icons/hicolor/512x512/apps/balena-etcher.png ]; then
      mkdir -p $out/share/pixmaps
      cp $out/share/icons/hicolor/512x512/apps/balena-etcher.png $out/share/pixmaps/
    fi
  '';

  meta = with lib; {
    description = "Flash OS images to SD cards & USB drives, safely and easily";
    homepage = "https://www.balena.io/etcher/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
