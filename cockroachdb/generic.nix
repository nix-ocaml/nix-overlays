{ stdenv
, lib
, cmake
, xz
, which
, autoconf
, ncurses6
, libedit
, libunwind
, installShellFiles
, removeReferencesTo
, go
, fetchpatch
, yacc
, perl
, ccache
, bazel
, git
, govers
, src
, version
, patches ? [ ]
}:

let
  isNewVersion = lib.versionOlder "21.2" version;
  darwinDeps = [ libunwind libedit ];
  linuxDeps = [ ncurses6 ];

  buildInputs = if stdenv.isDarwin then darwinDeps else linuxDeps;
  nativeBuildInputs =
    [ installShellFiles cmake xz which autoconf removeReferencesTo go govers ]
    ++ lib.optional isNewVersion [ yacc git perl ];

  patch = (fetchpatch {
    # https://github.com/cockroachdb/cockroach/issues/72529
    url = https://github.com/cockroachdb/krb5/commit/f78edbe30816f049e1360cb6e203fabfdf7b98df.patch;
    sha256 = "07hq1ks99piamdhiqk7klvvdai0s54bpxv9nn4zlki88zr13sc8g";
  });
  postConfigure =
    if isNewVersion then ''
      pushd src/github.com/cockroachdb/cockroach/c-deps/krb5/src
      patch -p1 aclocal.m4 ${patch}
      rm -rf ./configure
      popd
    '' else ''
      mkdir $NIX_BUILD_TOP/go
      export GOPATH=$NIX_BUILD_TOP/go
    '';

in
stdenv.mkDerivation rec {
  pname = "cockroach";
  inherit version src patches;

  goPackagePath = "github.com/cockroachdb/cockroach";

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [ "-Wno-error=deprecated-copy" "-Wno-error=redundant-move" "-Wno-error=pessimizing-move" ];

  inherit nativeBuildInputs buildInputs;
  configurePhase = ''
    export GOCACHE=$TMPDIR/go-cache
    mkdir fake-home
    export HOME=$PWD/fake-home
    ${postConfigure}
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

  meta = with lib; {
    homepage = "https://www.cockroachlabs.com";
    description = "A scalable, survivable, strongly-consistent SQL database";
    license = licenses.bsl11;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
    maintainers = with maintainers; [ rushmorem thoughtpolice rvolosatovs ];
  };
}
