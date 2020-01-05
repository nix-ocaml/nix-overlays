{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildLambdaRuntime = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "aws-lambda-ocaml-runtime";
      rev = "148027b";
      sha256 = "1m0aph410c4c2j9516gy5r2waj85v3181dps854vv1820zr6si0b";
    };
  } // args);

in rec {
  lambda-runtime = buildLambdaRuntime {
    pname = "lambda-runtime";
    propagatedBuildInputs = [ yojson ppx_deriving_yojson piaf uri logs lwt4 ];
  };

  now = buildLambdaRuntime {
    pname = "now";
    propagatedBuildInputs = [
      lambda-runtime
      httpaf
      yojson
      ppx_deriving_yojson
      lwt4
      base64
    ];
  };
}
