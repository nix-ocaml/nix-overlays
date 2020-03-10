{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildLambdaRuntime = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "aws-lambda-ocaml-runtime";
      rev = "c9972900746f0d1cd3b2d5e76550368509132b47";
      sha256 = "0hba50kvfgsafvh1gll4sy3n5z93vqf3jllaps5vbvwmrqqh52qx";
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
