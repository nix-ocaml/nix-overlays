{ fetchFromGitHub, buildDunePackage, cppo, cmdliner, melange-compiler-libs, base64 }:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "4675df6";
    sha256 = "sha256-LhJGVvRfW2oomMvkPIq326rgccXbRCFbk7GsbVdtv4k=";
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
