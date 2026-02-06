# nix-packages

This repository contains my custom Nix package expressions and small helper modules/overlays that I import as an input into my personal Nix flake for system configuration.

Key points

- This repo is intended to be used as a flake input and exposes:
  - an attribute `packages` (imported from `./packages`) so other flakes or your system flake can use these derivations directly.
  - `overlays.default` so you can add the packages as an overlay to an existing nixpkgs set.

How to use (examples)

- Build a package from this flake (replace system if needed):

```bash
nix --extra-experimental-features 'nix-command flakes' build .#packages.x86_64-linux.cre-cli -L
```

- Run the built binary (may need a graphical session for GUI apps):

```bash
./result/bin/cre version
```

Repository packages

The following packages are currently provided in `./packages`.

- cre-cli — Chainlink CRE CLI
  - path: `./packages/cre-cli`
  - note: small CLI packaged from upstream releases (no package README present)

- portmaster — Safing Portmaster (GUI application)
  - path: `./packages/portmaster`
  - package README: `./packages/portmaster/README.md`

Adding or updating packages

- To add a new package, create a directory under `packages/` with a `default.nix` that follows the repository style (exported as `pkgs: ...` and returns a derivation). See the existing packages for examples.

- To update a package that fetches a prebuilt asset (tarball, deb, zip):
  1. Update the `version` and `src` URL in the package's `default.nix`.

2. . Update the `version` and `src` URL in the package's `default.nix`.

1. Run `nix-prefetch-url --unpack <asset-url>` or run a `nix build` and copy the sha256 reported by Nix into the `sha256` field.

Notes & caveats

- GUI applications (like `portmaster`) often require systemd, DBus and a graphical session. They may run but print errors when executed in a headless build environment. Wire them into your NixOS configuration (systemd user service or XDG autostart) for proper behavior — see `packages/portmaster/README.md`.

- If you want me to add more packages, a module to expose them, or to clean up README markdown linting, tell me which item to do next and I will implement it.

Contact

If you need changes to a package, open an issue or ask here and I will help improve the derivation (add ldd2-35 variants, signature verification, multi-arch hashes, etc.).
