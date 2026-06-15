{ pkgs, ... }:

# Export packages using `pkgs.callPackage` so package expressions receive the
# usual Nixpkgs arguments (lib, stdenv, fetchurl, etc.). This makes writing
# package files simpler — they can assume the standard Nixpkgs callPackage
# signature.

{
  cre-cli = pkgs.callPackage ./cre-cli {};

  obs-face-tracker = pkgs.callPackage ./obs-face-tracker {};

  portmaster = pkgs.callPackage ./portmaster {};

  ankama-launcher = pkgs.callPackage ./ankama-launcher {};

  balena-etcher = pkgs.callPackage ./balena-etcher {};

  parsec = pkgs.callPackage ./parsec {};
}
