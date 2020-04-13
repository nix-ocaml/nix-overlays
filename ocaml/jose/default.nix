{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "jose";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "reason-jose";
    rev = "c5287f2891f20b584ec5ed0b3d0b0b37f1f194d7";
    sha256 = "1any6g46naxk0s9j1c5kmdx02398b8q0kh01prhrbb21xia6y5xl";
  };

  propagatedBuildInputs = [
    base64
    mirage-crypto
    x509
    cstruct
    astring
    yojson
    zarith
  ];
}
