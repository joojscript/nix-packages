{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.portmaster;
in
{
  options.services.portmaster = {
    enable = mkEnableOption "Safing Portmaster";

    autoConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically configure Portmaster";
    };

    startOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Start Portmaster on system boot";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      portmaster
    ];

    systemd.services.portmaster = mkIf cfg.startOnBoot {
      description = "Safing Portmaster";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.portmaster}/bin/portmaster";
        Restart = "on-failure";
        User = "root";
      };
    };

    # Required for Portmaster to function properly
    networking.firewall.enable = true;

    # Portmaster needs these capabilities
    security.wrappers = {
      portmaster = {
        source = "${pkgs.portmaster}/bin/portmaster";
        capabilities = "cap_net_admin,cap_net_raw,cap_sys_admin=ep";
      };
    };
  };
}
