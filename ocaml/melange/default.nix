{ buildDunePackage, cppo, cmdliner, melange-compiler-libs, base64 }:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/releases/download/0.3.0/melange-0.3.0.tbz;
    sha256 = "1s52vvrnzknd5azv8kx6wpydhhxjhz7x9jyvivskwhhagvnddw6x";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ cmdliner melange-compiler-libs base64 ];

  installPhase = ''
    runHook preInstall
    dune install --prefix $out ${pname}
    runHook postInstall
  '';
}
