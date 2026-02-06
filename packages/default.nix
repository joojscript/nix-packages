{ pkgs }:
let
  portmaster = import ./portmaster { inherit pkgs; };
  cre-cli = import ./cre-cli { inherit pkgs; };
in
{
  inherit (portmaster) portmaster;
  inherit (cre-cli) cre-cli;
}
