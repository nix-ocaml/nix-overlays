{ fetchFromGitHub, buildDunePackage, cppo, cmdliner, melange-compiler-libs, base64 }:

buildDunePackage rec {
  pname = "melange";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange";
    rev = "0c1aa1f8e1754c6810222a7a54e02e1adc337abe";
    sha256 = "sha256-c4rONqHxGaW31WmFDPSWCJ5Z+IKJXiAUei6n4VaqqXQ=";
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
