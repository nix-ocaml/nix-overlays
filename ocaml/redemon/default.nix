{ lib, fetchFromGitHub, buildDunePackage, luv, cmdliner, logs, fmt }:

buildDunePackage {
  pname = "redemon";
  version = "0.4.0";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "redemon";
    rev = "0.4.0";
    sha256 = "sha256-M3tBxNLjEkZmmVbjqBmMRMK1cmiNTzxYfnPvnk3jfAE=";
  };

  propagatedBuildInputs = [ luv cmdliner logs fmt ];

  meta = {
    description = "nodemon replacement written in OCaml, with luv";
    license = lib.licenses.mit;
  };
}
