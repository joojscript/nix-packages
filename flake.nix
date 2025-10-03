{
  description = "joojscript's custom Nix derivations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Apply our overlay to get our packages
        pkgsWithOverlay = pkgs.extend self.overlays.default;
      in
      {
        # Export packages for direct use (uses our own nixpkgs)
        packages = import ./packages { inherit pkgs; };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
          ];
        };
      }
    )
    // {
      # NixOS modules
      nixosModules = import ./modules;

      # Main overlay that other flakes can use
      overlays.default = final: prev: import ./packages { pkgs = final; };

      # Legacy overlay name for compatibility
      overlay = self.overlays.default;

      # Function to get packages with custom nixpkgs
      lib.mkPackages = pkgs: import ./packages { inherit pkgs; };
    };
}
