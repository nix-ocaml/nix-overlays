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
    rev = "57267505603cef4395906af40dfc295a3dc1efda";
    hash = "sha256-Hwe+KSmZIVi3GWXpabEyDb+WdT5Qb7lW9oRxJ6H2BbM=";
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
