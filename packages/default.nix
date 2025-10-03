{ pkgs }:
let
  portmaster = import ./portmaster { inherit pkgs; };
in
{
  inherit (portmaster) portmaster;
}
