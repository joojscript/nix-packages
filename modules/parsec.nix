{ config, pkgs, ... }:
let parsec = pkgs.parsec; in {
  environment.systemPackages = [ parsec ];

  xdg.desktopEntries.parsec = {
    name = "Parsec";
    genericName = "Remote Desktop";
    comment = "Parsec Remote Gaming and Desktop";
    exec = "${parsec}/bin/parsec";
    terminal = false;
    categories = [ "Network" "RemoteAccess" ];
    startupNotify = true;
  };
}
