{ buildDunePackage
, fetchFromGitHub
, yojson
, ppx_deriving_yojson
, piaf
, uri
, logs
, lwt
}:

buildDunePackage {
  pname = "lambda-runtime";
  version = "0.1.0-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "aws-lambda-ocaml-runtime";
    rev = "fd4ac1c3d83a36b3dc1d95eba0093f3d81f68dd4";
    hash = "sha256-oBr0ncC7TrzWhmIGTLbeW5qVbPgy/jDGegHcuMaDAik=";
  };

  propagatedBuildInputs = [
    yojson
    ppx_deriving_yojson
    piaf
    uri
    logs
    lwt
  ];
}
