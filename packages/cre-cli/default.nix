{ pkgs }:

let
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
in
pkgs.stdenv.mkDerivation rec {
  pname = "cre-cli";
  version = "v1.0.8"; # update as needed

  # Choose the appropriate release asset for the system
  asset = if stdenv.isx86_64 then "cre_linux_amd64.tar.gz" else "cre_linux_arm64.tar.gz";
  srcUrl = "https://github.com/smartcontractkit/cre-cli/releases/download/${version}/${asset}";

  src = fetchurl {
    url = srcUrl;
    # For x86_64 we observed this hash when fetching v1.0.8; keep the arm64 value as-is.
    sha256 = if stdenv.isx86_64 then "sha256-HN95/rBSmUA/ljo+7yjKzNgZckgXUO1rW9gq/p7fkhc=" else "0jj9wx26m6jvf1c1zg9fz95fvxyrr9bm2rca6xd20xlkrks52mmk";
  };

  nativeBuildInputs = [ pkgs.unzip ];

  # The release tarball contains the `cre` binary; extract and install it.
  unpackPhase = ''
    mkdir -p source
    tar -xzf $src -C source
  '';

  installPhase = ''
    mkdir -p $out/bin
    # Copy the cre binary (asset contains a file named like `cre*`)
    cp source/cre* $out/bin/cre
    chmod +x $out/bin/cre
  '';

  meta = with lib; {
    description = "Chainlink CRE CLI (cre)";
    homepage = "https://github.com/smartcontractkit/cre-cli";
    # Assumed license; please verify and adjust if necessary.
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ "joojscript" ];
  };
}
