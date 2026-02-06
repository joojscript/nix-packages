{ pkgs }:
let
  portmaster = import ./portmaster { inherit pkgs; };
in
{
  inherit (portmaster) portmaster;
  # Directly expose the cre-cli derivation
  cre-cli = import ./cre-cli { inherit pkgs; };
}
