# https://github.com/balena-io/etcher/releases/download/v1.7.9/balenaEtcher-1.7.9-x64.AppImage

{ appimageTools
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
, libXinerama
, libXi
, libXext
, libX11
, mesa
, gcc
, patchelf
, makeWrapper
}:

let
  pname = "balena-etcher";
  version = "1.7.9";
  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
    sha256 = "0kq2arf1q7nqr2m6cqhvky6cfbhlzdr7fxiwlgiprsppki89rdxx";
  };

  # List all required runtime libraries
  runtimeLibs = lib.makeLibraryPath [
    glib
    gtk3
    libxshmfence
    libxcb
    libxkbcommon
    libxcursor
    libxrandr
    libXinerama
    libXi
    libXext
    libX11
    mesa
    gcc.cc.lib
  ];
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    appimageTools.appimage-exec
    patchelf
    makeWrapper
  ];

  buildInputs = [
    glib
    gtk3
    libxshmfence
    libxcb
    libxkbcommon
    libxcursor
    libxrandr
    libXinerama
    libXi
    libXext
    libX11
    mesa
    gcc.cc.lib
  ];

  unpackPhase = ''
    mkdir -p app
    cd app
    ${appimageTools.appimage-exec}/bin/appimage-exec $src sh -c 'cp -r * "$1"' -- .
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/{applications,pixmaps,balena-etcher}

    # Copy the extracted AppImage content
    cp -r app/* $out/share/balena-etcher/

    # Find and wrap the main executable
    BINARY=$out/share/balena-etcher/balena-etcher-electron.bin
    
    if [ -f "$BINARY" ]; then
      # Use patchelf to set interpreter and RPATH
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
               --set-rpath "${runtimeLibs}:$out/share/balena-etcher" \
               "$BINARY" || true
      
      # Create wrapper script
      makeWrapper "$BINARY" $out/bin/balena-etcher \
        --set LD_LIBRARY_PATH "${runtimeLibs}:$out/share/balena-etcher"
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
