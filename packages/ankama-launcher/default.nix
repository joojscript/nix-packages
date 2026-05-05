{ pkgs }:

let
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
in
{
  linuxSrc = "https://launcher.cdn.ankama.com/installers/production/Ankama%20Launcher-Setup-x86_64.AppImage";
  macSrc = "https://launcher.cdn.ankama.com/installers/production/Ankama%20Launcher-Setup-x64.dmg";

  meta = with lib; {
    description = "Ankama Launcher";
    homepage = "https://www.ankama.com/en/launcher";
    # Assumed license; please verify and adjust if necessary.
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ "joojscript" ];
  };
}