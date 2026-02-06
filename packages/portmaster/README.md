# Portmaster package notes

This file documents how the `portmaster` package in this repo is packaged and how to enable autostart/launch on NixOS.

Why this README exists

- `Portmaster` is a GUI application distributed as a prebuilt `.deb` by Safing (https://safing.io/).
- The Nix derivation in `default.nix` unpacks the `.deb`, installs files into `$out`, and fixes runtime linking with `autoPatchelf` and a small wrapper so the binary can run on NixOS.
- Because this is a GUI application that expects system services (systemd, DBus) and a graphical environment, you should wire it into your NixOS configuration (systemd user service or XDG autostart) so it starts correctly in a real session. This README contains ready-to-paste snippets.

Quick test (local)

1. Build the package from the flake root:

```bash
nix --extra-experimental-features 'nix-command flakes' build .#packages.x86_64-linux.portmaster -L
```

2. Inspect the result and try running the binary (may require a graphical session and systemd):

```bash
./result/bin/portmaster --help
./result/bin/portmaster --version
```

You will likely see errors about `systemctl` or display/GBM when running outside a full graphical session — those are expected in a minimal build environment. On a regular NixOS desktop with systemd and a display, the program should run once wired in.

Option A — systemd user service (recommended)

Add the following to your NixOS system configuration (flake or `configuration.nix`) to run Portmaster as a user service on login:

```nix
# Example snippet to add to your configuration
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ portmaster ];

  systemd.user.services.portmaster = {
    description = "Safing Portmaster (user)";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.portmaster}/bin/portmaster --data=${pkgs.portmaster}/var/lib/portmaster";
      Restart = "on-failure";
    };
  };
}
```

Notes for Option A

- To allow a user service to run even when the user is not logged in, enable lingering: `sudo loginctl enable-linger <username>`.
- If the service fails due to display/DBus environment variables, adapt `serviceConfig.Environment` to set `DISPLAY` or `XDG_RUNTIME_DIR` as needed.

Option B — XDG desktop autostart (DE autostart)

If you prefer the desktop's autostart mechanism, ensure the `.desktop` file is available in `/etc/xdg/autostart` for system-wide autostart or `~/.config/autostart` for per-user autostart. Example (system activation script approach):

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ portmaster ];

  system.activationScripts.portmaster-autostart = {
    text = ''
      mkdir -p $out/etc/xdg/autostart || true
      cp -f ${pkgs.portmaster}/share/applications/Portmaster.desktop $out/etc/xdg/autostart/Portmaster.desktop || true
    '';
  };
}
```

Notes for Option B

- Most desktop environments will start entries in `/etc/xdg/autostart` on graphical login.
- You can also manage user autostart entries with Home Manager.

Option C — small reusable module file

If you want a reusable module, drop this file in `modules/portmaster.nix` and add it to your flake `modules` list.

```nix
# modules/portmaster.nix
{ lib, config, pkgs, ... }:

let
  port = pkgs.portmaster;
in {
  options.services.portmaster = lib.mkEnableOption "Enable Portmaster user service/autostart";
  config = lib.mkIf config.services.portmaster.enable {
    environment.systemPackages = lib.mkForce (config.environment.systemPackages ++ [ port ]);

    systemd.user.services.portmaster = {
      description = "Safing Portmaster (user)";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${port}/bin/portmaster --data=${port}/var/lib/portmaster";
        Restart = "on-failure";
      };
    };
  };
}
```

How to add the module to your flake

- Place `modules/portmaster.nix` in your flake and add its path to the modules list (for example in `nixosConfigurations.<host>.modules` or your global `modules` list):

```nix
modules = [ ./modules/portmaster.nix ... ];
```

Then enable it in your machine configuration:

```nix
services.portmaster.enable = true;
```

Testing & troubleshooting

- After changing your configuration, rebuild: `nixos-rebuild switch --flake .#<your-host>`
- Check the user service status after logging in:

```bash
loginctl --user status
systemctl --user status portmaster
journalctl --user -u portmaster -f
```

- If the app fails because it cannot find `systemctl` or the Portmaster API, ensure the system has `systemd` (it will on NixOS) and that any required helper services (the Portmaster API service) are available.
- If the app cannot create GBM buffers or fails to start the GUI, make sure you are running under a graphical session (Wayland/X11) and that the user has access to GPU/display.

Notes about packaging & updates

- The derivation in `default.nix` unpacks a `.deb` from Safing's updates server. If you want to update the package version, change the `version` (and the `src` URL if necessary) and re-run `nix-prefetch-url --unpack <asset-url>` to get the new `sha256`.
- This package currently targets `x86_64-linux`. If you need other arches, you may need different upstream assets.

Security & licensing

- The package metadata states the license as `GPL-3.0+` — verify this against upstream sources if required for compliance.

If you'd like, I can commit the `modules/portmaster.nix` file into this repo and/or add the README to the repo (this file is already created next to `default.nix`).

---

his package currently targets `x86_64-linux`. If you need other arches, you may need different upstream assets.

Security & licensing

- The package metadata states the license as `GPL-3.0+` — verify this against upstream sources if required for compliance.

If you'd like, I can commit the `modules/portmaster.nix` file into this repo and/or add the README to the repo (this file is already created next to `default.nix`).

---

If you want any of the above committed in this repo (module file or changes to `modules/default.nix` to export it), tell me and I'll make the edits and commit them with a clear message.
