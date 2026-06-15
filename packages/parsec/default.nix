{ pkgs, lib, ... }:

let
  version = "150-97"; # Update when Parsec releases new versions

  parsecAppImage = pkgs.fetchurl {
    url = "https://builds.parsec.app/package/parsec-linux.deb";
    sha256 = "sha256-8Wkbo6l1NGBPX2QMJszq+u9nLM96tu7WYRTQq6/CzM8=";
  };

  parsec = pkgs.stdenv.mkDerivation rec {
    pname = "parsec";
    inherit version;

    src = parsecAppImage;

    nativeBuildInputs = [ pkgs.dpkg pkgs.cpio ];

    buildPhase = ''
      mkdir -p $out/bin
      mkdir work
      cd work

      dpkg-deb -x ${parsecAppImage} .

      APPIMAGE=$(find . -name "*.AppImage" | head -n1 || true)
      if [ -n "$APPIMAGE" ]; then
        cp "$APPIMAGE" $out/Parsec.AppImage
        chmod +x $out/Parsec.AppImage
        cat > $out/bin/parsec <<'EOF'
#!/bin/sh
HERE=$(dirname "$0")
exec "$HERE/../Parsec.AppImage" "$@"
EOF
        chmod +x $out/bin/parsec
      else
        # Copy any executables from usr/bin (many .deb packages place bins there)
        if [ -d usr/bin ]; then
          for f in usr/bin/*; do
            if [ -f "$f" ] && [ -x "$f" ]; then
              cp "$f" $out/bin/$(basename "$f")
            fi
          done

          # Provide a convenient `parsec` wrapper that runs `parsecd` if present
          if [ -x "$out/bin/parsecd" ]; then
            cat > $out/bin/parsec <<'EOF'
#!/bin/sh
HERE=$(dirname "$0")
exec "$HERE/parsecd" "$@"
EOF
            chmod +x $out/bin/parsec
          else
            # If no parsecd, pick the first executable as a fallback
            FIRST=$(ls $out/bin | head -n1 || true)
            if [ -n "$FIRST" ]; then
              cat > $out/bin/parsec <<'EOF'
#!/bin/sh
HERE=$(dirname "$0")
exec "$HERE/$FIRST" "$@"
EOF
              chmod +x $out/bin/parsec
            else
              echo "no executables found inside deb" >&2
              exit 1
            fi
          fi
        else
          echo "no usr/bin in deb" >&2
          exit 1
        fi
      fi
    '';

    installPhase = ''
      # everything already placed into $out during buildPhase
      true
    '';

    meta = with pkgs.lib; {
      description = "Parsec remote desktop";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  };

in
  parsec
