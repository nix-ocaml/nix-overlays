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
    rev = "5d3210e0c6683f390cb5870efe7f774420ad4b22";
    sha256 = "sha256-U0s2nj78dmA1+sC8zDiERKAv5zqI81GV76VLoHiCO5w=";
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
