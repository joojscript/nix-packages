{ pkgs }:
{
  # Directly expose the cre-cli derivation
  cre-cli = import ./cre-cli { inherit pkgs; };
  # Safing Portmaster application package
  portmaster = import ./portmaster { inherit pkgs; };
}
