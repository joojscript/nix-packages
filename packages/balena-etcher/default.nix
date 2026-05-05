# https://github.com/balena-io/etcher/releases/download/v1.7.9/balenaEtcher-1.7.9-x64.AppImage

{ appimageTools
, fetchurl
, lib
, stdenv
, dbus
, dbus-glib
, gdk-pixbuf
, glib
, gtk2
, gtk3
, libappindicator
, alsa-lib
, libdrm
, libxcb
, libxcursor
, libxkbcommon
, libxrandr
, libxshmfence
, libX11
, libXext
, libXi
, libXinerama
, mesa
, nss
, gcc
, makeWrapper
}:

let
  pname = "balena-etcher";
  version = "1.7.9";
  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
    sha256 = "0kq2arf1q7nqr2m6cqhvky6cfbhlzdr7fxiwlgiprsppki89rdxx";
  };

  # Extract AppImage using appimageTools
  appimage = appimageTools.extract { 
    inherit pname version src;
  };

  # List all required runtime libraries
  runtimeLibs = lib.makeLibraryPath [
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gtk2
    gtk3
    libappindicator
    alsa-lib
    libdrm
    libxcb
    libxcursor
    libxkbcommon
    libxrandr
    libxshmfence
    libX11
    libXext
    libXi
    libXinerama
    mesa
    nss
    gcc.cc.lib
  ];
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gtk2
    gtk3
    libappindicator
    alsa-lib
    libdrm
    libxcb
    libxcursor
    libxkbcommon
    libxrandr
    libxshmfence
    libX11
    libXext
    libXi
    libXinerama
    mesa
    nss
    gcc.cc.lib
  ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin $out/share/{applications,pixmaps,balena-etcher}

    # Copy the extracted AppImage content
    cp -r ${appimage}/* $out/share/balena-etcher/

    # Find and wrap the main executable
    BINARY=$out/share/balena-etcher/balena-etcher-electron.bin
    
    if [ -f "$BINARY" ]; then
      # Create wrapper script that sets up library paths
      makeWrapper "$BINARY" $out/bin/balena-etcher \
        --set LD_LIBRARY_PATH "${runtimeLibs}:$out/share/balena-etcher/lib:$out/share/balena-etcher/usr/lib"
    fi

    # Create desktop entry
    cat > $out/share/applications/balena-etcher.desktop << EOF
[Desktop Entry]
Type=Application
Name=Balena Etcher
Exec=$out/bin/balena-etcher %F
Icon=balena-etcher
Comment=Flash OS images to SD cards & USB drives
Categories=Utility;
EOF

    # Try to copy icon
    if [ -f $out/share/balena-etcher/balena-etcher.png ]; then
      cp $out/share/balena-etcher/balena-etcher.png $out/share/pixmaps/
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
