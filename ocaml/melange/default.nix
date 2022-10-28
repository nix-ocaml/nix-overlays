{ buildDunePackage, cppo, cmdliner, melange-compiler-libs, reason, base64 }:

buildDunePackage rec {
  pname = "melange";
  version = "0.2.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/b481d7b.tar.gz;
    sha256 = "1l0a94gg1d3cxn43vi2pxn3q08j73cxxwbqxi4q8q71gjq09kpg8";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ cmdliner melange-compiler-libs reason base64 ];

  installPhase = ''
    runHook preInstall
    dune install --prefix $out ${pname}
    runHook postInstall
  '';
}
