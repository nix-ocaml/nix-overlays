{ buildDunePackage, cppo, cmdliner, melange-compiler-libs, reason, base64 }:

buildDunePackage rec {
  pname = "melange";
  version = "0.2.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/0aa8e5a.tar.gz;
    sha256 = "1ln7d8lbq0ybnk44ims0kqdrvglm8m6qck211zr2cy2xv4hshl8s";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ cmdliner melange-compiler-libs reason base64 ];

  installPhase = ''
    runHook preInstall
    dune install --prefix $out ${pname}
    runHook postInstall
  '';
}
