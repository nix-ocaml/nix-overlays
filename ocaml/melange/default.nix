{ buildDunePackage, cppo, cmdliner, melange-compiler-libs, base64 }:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange/archive/4675df6.tar.gz;
    sha256 = "0iv0ycsmcjkid3iqpwbca570a5g3q9jp5nhwdmdadfpavnv4kmrc";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ cmdliner melange-compiler-libs base64 ];

  installPhase = ''
    runHook preInstall
    dune install --prefix $out ${pname}
    runHook postInstall
  '';

  meta.mainProgram = "melc";
}
