{ stdenv, fetchurl
, cmake, xz, which, autoconf
, ncurses6, libedit, libunwind
, installShellFiles, lib
, removeReferencesTo, go, govers
}:

let
  darwinDeps = [ libunwind libedit ];
  linuxDeps  = [ ncurses6 ];

  buildInputs = if stdenv.isDarwin then darwinDeps else linuxDeps;
  nativeBuildInputs = [ installShellFiles cmake xz which autoconf removeReferencesTo go govers ];

in
stdenv.mkDerivation rec {
  pname = "cockroach";
  version = "20.2.0";

  goPackagePath = "github.com/cockroachdb/cockroach";

  src = fetchurl {
    url = "https://binaries.cockroachdb.com/cockroach-v${version}.src.tgz";
    sha256 = "0g3bx1fmw1yqchqmnrw58550qfdzmc837hvg4z0ldbmxzcxwaiqw";
  };

  NIX_CFLAGS_COMPILE = stdenv.lib.optionals stdenv.cc.isGNU [ "-Wno-error=deprecated-copy" "-Wno-error=redundant-move" "-Wno-error=pessimizing-move" ];

  inherit nativeBuildInputs buildInputs;
  configurePhase = ''
    mkdir $NIX_BUILD_TOP/go
    export GOPATH=$NIX_BUILD_TOP/go
    export GOCACHE=$TMPDIR/go-cache
  '';

  buildPhase = ''
    runHook preBuild
    patchShebangs .
    make buildoss
    cd src/${goPackagePath}
    for asset in man autocomplete; do
      ./cockroachoss gen $asset
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D cockroachoss $out/bin/cockroach
    installShellCompletion cockroach.bash

    mkdir -p $man/share/man
    cp -r man $man/share/man

    runHook postInstall
  '';

  outputs = [ "out" "man" ];

  meta = with stdenv.lib; {
    homepage    = "https://www.cockroachlabs.com";
    description = "A scalable, survivable, strongly-consistent SQL database";
    license     = licenses.bsl11;
    platforms   = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
    maintainers = with maintainers; [ rushmorem thoughtpolice rvolosatovs ];
  };
}
