{
  lib,
  stdenv,
  dpkg,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glibc,
  gcc,
  systemd,
  libnotify,
  nss,
  nspr,
  atk,
  at-spi2-atk,
  cups,
  pango,
  gdk-pixbuf,
  gtk3,
  cairo,
  dbus,
  expat,
  xorg,
  alsa-lib,
  mesa,
  libxkbcommon,
  libappindicator-gtk3,
  webkitgtk_4_1,
  libsoup_3,
}:

stdenv.mkDerivation rec {
  pname = "portmaster";
  version = "2.0.25";

  src = fetchurl {
    url = "https://updates.safing.io/latest/linux_amd64/packages/Portmaster_2.0.25_amd64.deb";
    sha256 = "0p6sgwjkjbd0wy0xgkbak6bgvqdb49hbg87a1apn361jvl006gh4";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs =
    [
      glibc
      gcc.cc.lib
      systemd
      libnotify
      nss
      nspr
      atk
      at-spi2-atk
      cups
      pango
      gdk-pixbuf
      gtk3
      cairo
      dbus
      expat
      alsa-lib
      mesa
      libxkbcommon
      libappindicator-gtk3
      webkitgtk_4_1
      libsoup_3
    ]
    ++ (with xorg; [
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libxcb
    ]);

  # Runtime dependencies
  runtimeDependencies = [
    systemd
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
    chmod -R u+w .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/

    # Copy additional files and data
    mkdir -p $out/var/lib/portmaster
    if [ -d var/lib/portmaster ]; then
      cp -r var/lib/portmaster/* $out/var/lib/portmaster/
    fi

    # Fix desktop file (note: file is named Portmaster.desktop, not portmaster.desktop)
    if [ -f $out/share/applications/Portmaster.desktop ]; then
      substituteInPlace $out/share/applications/Portmaster.desktop \
        --replace "Exec=portmaster --data=/opt/safing/portmaster" "Exec=$out/bin/portmaster --data=$out/var/lib/portmaster" \
        --replace "Icon=portmaster" "Icon=$out/share/icons/hicolor/512x512/apps/portmaster.png"
    fi

    # Also copy the autostart file and fix it
    mkdir -p $out/etc/xdg/autostart
    if [ -f etc/xdg/autostart/portmaster.desktop ]; then
      cp etc/xdg/autostart/portmaster.desktop $out/etc/xdg/autostart/
      substituteInPlace $out/etc/xdg/autostart/portmaster.desktop \
        --replace "Exec=portmaster --data=/opt/safing/portmaster" "Exec=$out/bin/portmaster --data=$out/var/lib/portmaster"
    fi
  '';

  postFixup = ''
    # Fix library paths
    find $out -type f -executable -print0 | xargs -0 autoPatchelf 2>/dev/null || true

    # Wrap the binary to ensure it finds all dependencies
    if [ -f $out/bin/portmaster ]; then
      wrapProgram $out/bin/portmaster \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
        --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}
    fi
  '';

  meta = with lib; {
    description = "Safing Portmaster - Application Firewall and Network Monitor";
    homepage = "https://safing.io/";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ "joojscript" ];
  };
}
