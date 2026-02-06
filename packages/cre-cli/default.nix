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

  nativeBuildInputs = [ pkgs.unzip pkgs.autoPatchelfHook pkgs.makeWrapper pkgs.patchelf ];
  buildInputs = [ pkgs.glibc pkgs.gcc.cc.lib ];

  # ELF interpreter for this architecture (used below in postFixup)
  interpreter = if stdenv.isx86_64 then "${pkgs.glibc}/lib/ld-linux-x86-64.so.2" else "${pkgs.glibc}/lib/ld-linux-aarch64.so.1";

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

  postFixup = ''
    # Ensure the binary uses the glibc from Nix store as the program interpreter
    if [ -f $out/bin/cre ]; then
      patchelf --set-interpreter ${interpreter} $out/bin/cre || true

      # Let autoPatchelf fix RPATHs for any dynamically linked objects it finds
      find $out -type f -executable -print0 | xargs -0 autoPatchelf 2>/dev/null || true

      # Wrap the binary so it finds libraries from buildInputs at runtime
      wrapProgram $out/bin/cre \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
        --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]} || true
    fi
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
