# https://github.com/balena-io/etcher/releases/download/v1.7.9/balenaEtcher-1.7.9-x64.AppImage

{ appimageTools, fetchurl, lib, stdenv }:

let
  pname = "balena-etcher";
  version = "1.7.9";
  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
    sha256 = "1hwqbgr414hpb0xc7ii3qfh12f168wvvgidx7p0zj36ad74scb71"; # Update this for x64 if needed
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Create desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/balena-etcher.desktop << EOF
[Desktop Entry]
Type=Application
Name=Balena Etcher
Exec=$out/bin/balena-etcher
Icon=balena-etcher
Comment=Flash OS images to SD cards & USB drives
Categories=Utility;
EOF

    # Copy icon if available (AppImage might have it)
    # Assuming the AppImage extracts to have an icon
    if [ -f $out/share/icons/hicolor/512x512/apps/balena-etcher.png ]; then
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
